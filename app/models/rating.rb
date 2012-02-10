class Rating < ActiveRecord::Base
  DefaultValue = 1000

  belongs_to :game
  belongs_to :player
  has_many :history_events, :class_name => "RatingHistoryEvent"

  def as_json(option = {})
    {
      :player => player.name,
      :value => value
    }
  end

  def to_elo
    Elo::Player.new(
      :rating => value,
      :games_played => player.results.where(:game_id => game.id).count,
      :pro => pro?
    )
  end
end
