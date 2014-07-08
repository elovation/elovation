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
      winning_teams = teams.select{|team| team.rank == Team::FIRST_PLACE_RANK}

      if winning_teams.size > 1
        first_rating, second_rating = winning_teams
          .map(&:players)
          .map(&:first)
          .map{ |player| player.ratings.find_or_create(game) }

        first_elo = to_elo(first_rating)
        second_elo = to_elo(second_rating)

        first_elo.plays_draw(second_elo)
      else
        winner = winning_teams.first.players.first
        loser = teams.detect{|team| team.rank != Team::FIRST_PLACE_RANK}.players.first

        first_rating = winner.ratings.find_or_create(game)
        second_rating = loser.ratings.find_or_create(game)

        first_elo = to_elo(first_rating)
        second_elo = to_elo(second_rating)

        first_elo.wins_from(second_elo)
      end

      _update_rating_from_elo(first_rating, first_elo)
      _update_rating_from_elo(second_rating, second_elo)
    end

    def to_elo rating
      Elo::Player.new(
        rating: rating.value,
        games_played: rating.player.results.where(game_id: rating.game.id).count,
        pro: rating.pro?
      )
    end

    def _update_rating_from_elo(rating, elo)
      Rating.transaction do
        rating.update_attributes!(value: elo.rating, pro: elo.pro?)
        rating.history_events.create!(value: elo.rating)
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
      ratings_to_ranks = teams.sort_by(&:rank).each_with_object({}){ |team, hash| hash[team.players.map{|player| player.ratings.find_or_create(game)}] = team.rank }

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
        attributes = { value: (trueskill.mean - (3.0 * trueskill.deviation)) * 100,
                       trueskill_mean: trueskill.mean,
                       trueskill_deviation: trueskill.deviation }
        rating.update_attributes! attributes
        rating.history_events.create! attributes
      end
    end
  end
end
