class Result < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to :winner, :class_name => "Player"
  belongs_to :loser, :class_name => "Player"
  belongs_to :game

  scope :most_recent_first, :order => "created_at desc"
  scope :for_game, lambda { |game| where(:game_id => game.id) }

  validates_presence_of :winner
  validates_presence_of :loser

  validate do |result|
    if result.winner == result.loser and not result.winner.nil?
      errors.add(:base, "Winner and loser can't be the same player")
    end
  end

  def as_json(options = {})
    {
      :winner => winner.name,
      :loser => loser.name,
      :created_at => created_at.utc.to_s
    }
  end

  def most_recent?
    players.all? do |player|
      player.results.where(:game_id => game.id).order("created_at DESC").first == self
    end
  end

  def self.find_winning_streaks(game)
    recent_losses_sql = select('game_id, loser_id as player_id, max(created_at) as loss_created_at').
                        group('game_id, loser_id').to_sql

    # count wins with created_at date after the most recent loss
    winning_streaks = select('winner_id, count(1) as winning_streak').
                      joins("left join (#{recent_losses_sql}) recent_losses on player_id = winner_id and recent_losses.game_id = results.game_id").
                      where(:game_id => game).
                      where('loss_created_at is null or created_at > loss_created_at').
                      group(:winner_id).
                      having('count(1) >= 3')

    return Hash[ winning_streaks.collect {|i| [i.winner_id.to_i, i.winning_streak.to_i] } ]
  end
end
