FactoryBot.define do
  factory :rating_history_event do
    rating
    state { rating.state }
    value { rating.game.rating_system.score(state) }
  end
end
