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

    def update_ratings game, teams
      winner = teams.detect{|team| team.rank == Team::FIRST_PLACE_RANK}.players.first
      winner_rating = winner.ratings.find_or_create(game)
      loser = teams.detect{|team| team.rank != Team::FIRST_PLACE_RANK}.players.first
      loser_rating = loser.ratings.find_or_create(game)

      winner_elo = winner_rating.to_elo
      loser_elo = loser_rating.to_elo

      winner_elo.wins_from(loser_elo)

      _update_rating_from_elo(winner_rating, winner_elo)
      _update_rating_from_elo(loser_rating, loser_elo)
    end

    def _update_rating_from_elo(rating, elo)
      Rating.transaction do
        rating.update_attributes!(:value => elo.rating, :pro => elo.pro?)
        rating.history_events.create!(:value => elo.rating)
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

    def update_ratings game, teams

    end
  end
end
