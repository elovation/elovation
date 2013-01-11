module Rater
  class Elo
    DefaultValue = 1000

    def default_attributes
      { value: DefaultValue }
    end

    def description
      "Elo (1v1 only)"
    end

    def validate_game game
      if game.min_number_of_teams != 2 ||
         game.max_number_of_teams != 2 ||
         game.min_number_of_players_per_team != 1 ||
         game.max_number_of_players_per_team != 1
        game.errors.add(:rating_type, "Elo can only be used with 1v1 games")
      end
    end
  end

  class Trueskill
    DefaultValue = 0

    def default_attributes
      { value: DefaultValue }
    end

    def description
      "Trueskill"
    end

    def validate_game game
    end
  end
end
