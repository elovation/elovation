FactoryGirl.define do
  factory :rating_history_event do
    value Rating::DefaultValue
    rating
  end
end
