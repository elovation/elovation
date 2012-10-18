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
end
