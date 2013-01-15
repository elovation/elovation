FactoryGirl.define do
  factory :result do
    game
    teams { [ FactoryGirl.build(:team, rank: 1),
              FactoryGirl.build(:team, rank: 2)] }

    before(:create) do |result|
      result.teams.map(&:save!)
    end
  end
end
