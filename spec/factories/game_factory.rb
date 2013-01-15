FactoryGirl.define do
  factory :game do
    name { Faker::Lorem.words(1).first.capitalize }
    rating_type "trueskill"
    min_number_of_teams 2
    max_number_of_teams 2
    min_number_of_players_per_team 1
    max_number_of_players_per_team 1
    allow_ties true

    factory :elo_game do
      rating_type "elo"
    end

    factory :trueskill_game do
      rating_type "trueskill"
    end
  end
end
