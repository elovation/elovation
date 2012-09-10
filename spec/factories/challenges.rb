FactoryGirl.define do
  factory :challenge do
    game
    association :challenger, :factory => :player
    association :challengee, :factory => :player
  end
end
