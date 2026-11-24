FactoryBot.define do
  factory :rating do
    game
    player
    pro { false }
    value { game.rating_system.score(game.rating_system.initial_state) }
    trueskill_mean { game.rating_system.initial_state["mean"] }
    trueskill_deviation { game.rating_system.initial_state["deviation"] }
  end
end
