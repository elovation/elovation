class Rating < ApplicationRecord
  belongs_to :game
  belongs_to :player

  has_many :history_events, -> { order created_at: :desc }, class_name: "RatingHistoryEvent", dependent: :destroy

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

  # Saves a new state and appends it to the rating's history.
  def record!(new_state)
    Rating.transaction do
      self.state = new_state
      save!
      history_events.create!(value: value, state: state)
    end
  end

  # Restores the previous state in the rating's history, or removes the
  # rating if it has no earlier history.
  def rewind!
    if history_events.count == 1
      destroy
    else
      Rating.transaction do
        update!(state: _previous_rating.state)
        _current_rating.destroy
      end
    end
  end

  def _current_rating
    history_events.first
  end

  def _previous_rating
    history_events.second
  end
end
