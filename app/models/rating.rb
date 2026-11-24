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

  # The rating system's state for this rating. Each rating system's state is
  # spread over its own columns here; only game.rating_system interprets it.
  def state
    case game.rating_type
    when "elo"
      { "rating" => value, "games_played" => history_events.count, "pro" => pro }
    when "trueskill"
      { "mean" => trueskill_mean, "deviation" => trueskill_deviation }
    end
  end

  def state=(new_state)
    self.value = game.rating_system.score(new_state)

    case game.rating_type
    when "elo"
      self.pro = new_state.fetch("pro")
    when "trueskill"
      self.trueskill_mean = new_state.fetch("mean")
      self.trueskill_deviation = new_state.fetch("deviation")
    end
  end

  # Saves a new state and appends it to the rating's history.
  def record!(new_state)
    Rating.transaction do
      self.state = new_state
      save!
      history_events.create!(value: value, trueskill_mean: trueskill_mean, trueskill_deviation: trueskill_deviation)
    end
  end

  def rewind!
    if history_events.count == 1
      destroy
    else
      Rating.transaction do
        update!(value: _previous_rating.value,
                           trueskill_mean: _previous_rating.trueskill_mean,
                           trueskill_deviation: _previous_rating.trueskill_deviation)
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
