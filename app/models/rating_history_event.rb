class RatingHistoryEvent < ActiveRecord::Base
  belongs_to :rating

  def most_recent?
    rating.history_events.first == self
  end
end
