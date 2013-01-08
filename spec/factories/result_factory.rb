FactoryGirl.define do
  factory :result do
    game

    ignore do
      winner false
      loser false
    end

    after(:build) do |result, evaluator|
      if evaluator.winner
        result.teams << FactoryGirl.build(:team, rank: 1, players: [evaluator.winner])
      else
        result.teams << FactoryGirl.build(:team, rank: 1)
      end

      if evaluator.loser
        result.teams << FactoryGirl.build(:team, rank: 2, players: [evaluator.loser])
      else
        result.teams << FactoryGirl.build(:team, rank: 2)
      end
    end
  end
end
