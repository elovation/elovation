FactoryGirl.define do
  factory :result do
    game
    association :winner, :factory => :player
  end
end
