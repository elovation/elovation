FactoryBot.define do
  factory :rating_history_event do
    value { rating.game.rating_system.score(rating.game.rating_system.initial_state) }
    rating
  end
end
