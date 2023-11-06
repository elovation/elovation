FactoryBot.define do
  factory(:result) do
    game
    teams do
      [FactoryBot.build(:team, rank: 1), FactoryBot.build(:team, rank: 2)]
    end

    before(:create) { |result| result.teams.map(&:save!) }
  end
end
