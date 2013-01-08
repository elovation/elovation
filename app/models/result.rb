class Result < ActiveRecord::Base
  has_many :teams
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

  def winner
    teams.detect{|team| team.rank == 1}.try(:players).try(:first)
  end

  def loser
    teams.detect{|team| team.rank == 2}.try(:players).try(:first)
  end

  def as_json(options = {})
    {
      :winner => winner.name,
      :loser => loser.name,
      :created_at => created_at.utc.to_s
    }
  end

  def most_recent?
    teams.all? do |team|
      team.players.all? do |player|
        player.results.where(:game_id => game.id).order("created_at DESC").first == self
      end
    end
  end
end
