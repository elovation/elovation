# frozen_string_literal: true

class RatingHistoryEvent < ApplicationRecord
  belongs_to :rating
end
