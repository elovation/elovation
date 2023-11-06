FactoryBot.define do
  factory(:game) do
    name { Faker::Lorem.word.capitalize }
    rating_type { "trueskill" }
    min_number_of_teams { 2 }
    max_number_of_teams { 2 }
    min_number_of_players_per_team { 1 }
    max_number_of_players_per_team { 1 }
    allow_ties { true }

    factory(:elo_game) { rating_type { "elo" } }

    factory(:trueskill_game) { rating_type { "trueskill" } }
  end
end
