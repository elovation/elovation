class RatingHistoryEvent < ActiveRecord::Base
  belongs_to :rating
  def value
    rating.game.rater.coerce_value(super)
  end
end
