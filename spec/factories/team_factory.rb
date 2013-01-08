FactoryGirl.define do
  factory :team do
    after(:build) do |team, evaluator|
      team.players << FactoryGirl.build(:player)
    end
  end
end
