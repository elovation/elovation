class Result < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to :winner, :class_name => "Player"
  belongs_to :loser, :class_name => "Player"
  belongs_to :game

  validate do |result|
    if result.winner == result.loser
      errors.add(:base, "Winner and loser can't be the same player")
    end
  end

  def as_json(options = {})
    {
      :winner => winner.name,
      :loser => loser.name
    }
  end
end
