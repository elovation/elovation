class Result < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to :winner, :class_name => "Player"
  belongs_to :game

  def player_1_id
    players.first.id
  end

  def player_2_id
    players.second.id
  end
end
