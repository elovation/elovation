module Rater
  class EloRater
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

      winner_elo = to_elo(winner_rating)
      loser_elo = to_elo(loser_rating)

      winner_elo.wins_from(loser_elo)

      _update_rating_from_elo(winner_rating, winner_elo)
      _update_rating_from_elo(loser_rating, loser_elo)
    end

    def to_elo rating
      Elo::Player.new(
        :rating => rating.value,
        :games_played => rating.player.results.where(:game_id => rating.game.id).count,
        :pro => rating.pro?
      )
    end

    def _update_rating_from_elo(rating, elo)
      Rating.transaction do
        rating.update_attributes!(:value => elo.rating, :pro => elo.pro?)
        rating.history_events.create!(:value => elo.rating)
      end
    end
  end

  class TrueSkillRater
    DefaultValue = 0
    DefaultMean = 25
    DefaultDeviation = 25.0/3.0

    def default_attributes
      { value: DefaultValue, trueskill_mean: DefaultMean, trueskill_deviation: DefaultDeviation }
    end

    def description
      "Trueskill"
    end

    def validate_game game
    end

    def update_ratings game, teams
      ratings_to_ranks = teams.each_with_object({}){ |team, hash| hash[team.players.map{|player| player.ratings.find_or_create(game)}] = team.rank }

      ratings_to_trueskill = {}
      trueskills_to_rank = ratings_to_ranks.each_with_object({}) do |(ratings, rank), hash|
        trueskills = ratings.map do |rating|
          ratings_to_trueskill[rating] = to_trueskill(rating)
        end

        hash[trueskills] = rank
      end

      graph = Saulabs::TrueSkill::FactorGraph.new trueskills_to_rank
      graph.update_skills

      ratings_to_trueskill.each do |rating, trueskill|
        _update_rating_from_trueskill rating, trueskill
      end
    end

    def to_trueskill rating
      Saulabs::TrueSkill::Rating.new(
        rating.trueskill_mean,
        rating.trueskill_deviation
      )
    end

    def _update_rating_from_trueskill rating, trueskill
      Rating.transaction do
        attributes = { value: (trueskill.mean - (3.0 * trueskill.deviation)),
                       trueskill_mean: trueskill.mean,
                       trueskill_deviation: trueskill.deviation }
        rating.update_attributes! attributes
        rating.history_events.create! attributes
      end
    end
  end
end
