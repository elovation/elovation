FactoryGirl.define do
  factory :result do
    game
    association :loser, :factory => :player
    association :winner, :factory => :player

    after_build do |result|
      result.players = [result.loser, result.winner]
    end
  end
end
