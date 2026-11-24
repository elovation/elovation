FactoryBot.define do
  factory :rating do
    game
    player
    # Assigning state also sets value (the score); pass value: to override it.
    state { game.rating_system.initial_state }
  end
end
