class RatingHistoryEvent < ActiveRecord::Base
  belongs_to :rating
  belongs_to :result
end
