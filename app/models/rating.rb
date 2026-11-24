class Rating < ApplicationRecord
  belongs_to :game
  belongs_to :player

  # Newest first. History is stamped with the time of the result it came from.
  has_many :history_events, -> { order created_at: :desc, id: :desc }, class_name: "RatingHistoryEvent", dependent: :destroy

  def active?
    if most_recent_result
      most_recent_result.created_at >= 4.weeks.ago
    else
      false
    end
  end

  def as_json(option = {})
    {
      player: player.as_json,
      value: value
    }
  end

  def most_recent_result
    player.results.for_game(game).most_recent_first.first
  end

  # `state` is the rating state: opaque to everything except game.rating_system.
  # Assigning it also sets `value`, the score derived from it.
  def state=(new_state)
    super
    self.value = game.rating_system.score(new_state)
  end
end
