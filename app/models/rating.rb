class Rating < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :history_events, :class_name => "RatingHistoryEvent", :dependent => :destroy, :order => "created_at DESC"

  def active?
    if most_recent_result
      most_recent_result.created_at >= 4.weeks.ago
    else
      false
    end
  end

  def as_json(option = {})
    {
      :player => player.as_json,
      :value => value
    }
  end

  def most_recent_result
    player.results.for_game(game).most_recent_first.first
  end

  def rewind!
    if history_events.count == 1
      destroy
    else
      Rating.transaction do
        update_attributes!(:value => _previous_rating.value)
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
