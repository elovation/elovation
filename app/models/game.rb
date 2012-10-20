class Game < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :results, :dependent => :destroy

  validates :name, :presence => true

  def all_ratings
    ratings.order("value DESC").includes([:player, :game])
  end

  def active_ratings
    all_ratings.where("updated_at >= '#{Rating.active_rating_threshold}'")
  end

  def as_json(options = {})
    {
      :name => name,
      :ratings => top_ratings.map(&:as_json),
      :results => recent_results.map(&:as_json)
    }
  end

  def players
    ratings.map(&:player)
  end

  def recent_results
    results.order("created_at DESC").limit(5).includes([:winner, :loser, :players])
  end

  def top_ratings
    ratings.order("value DESC").limit(5)
  end

  def wins_and_losses
    wins_by_player = Hash[ results.select('winner_id, count(1) as wins').group(:winner_id).collect {|i| [i.winner_id, i.wins]} ]
    losses_by_player = Hash[ results.select('loser_id, count(1) as losses').group(:loser_id).collect {|i| [i.loser_id, i.losses]} ]
    return Hash[ Player.all.collect { |p| [ p.id, { :wins => wins_by_player[p.id].to_i, :losses => losses_by_player[p.id].to_i } ] } ]
  end

  def wins_and_losses_against(player)
    wins_by_player = Hash[ results.select('winner_id, count(1) as wins').where(:loser_id => player).group(:winner_id).collect {|i| [i.winner_id, i.wins]} ]
    losses_by_player = Hash[ results.select('loser_id, count(1) as losses').where(:winner_id => player).group(:loser_id).collect {|i| [i.loser_id, i.losses]} ]
    return Hash[ Player.all.collect { |p| [ p.id, { :wins => wins_by_player[p.id].to_i, :losses => losses_by_player[p.id].to_i } ] } ]
  end
end
