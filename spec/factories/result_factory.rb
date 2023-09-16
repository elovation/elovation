FactoryBot.define do
  factory :result do
    game
    teams { [ FactoryBot.build(:team, rank: 1),
              FactoryBot.build(:team, rank: 2)] }

    before(:create) do |result|
      result.teams.map(&:save!)
    end
  end
end
