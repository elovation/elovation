FactoryGirl.define do
  factory :rating_history_event do
    value { rating.game.rater.default_attributes[:value] }
    rating
  end
end
