# frozen_string_literal: true

module RatingSystems
  # Elo for one-on-one games, with FIDE K-factors.
  #
  # State: { "rating" => Integer, "games_played" => Integer, "pro" => Boolean }
  #
  # - New ratings are truncated toward zero (as the elo gem this replaced did).
  # - K is 10 for a pro (a player who has ever reached 2400) or anyone rated
  #   2400+, otherwise 25 for a starter (fewer than 30 games played before this
  #   one), otherwise 15.
  module Elo
    extend self

    DEFAULT_RATING = 1000
    PRO_RATING = 2400
    STARTER_GAMES = 30
    PRO_K_FACTOR = 10
    STARTER_K_FACTOR = 25
    K_FACTOR = 15

    def key = 'elo'

    def name = 'Elo'

    def description = 'Elo (1v1 only)'

    def supported_format
      Format.new(teams: 2..2, players_per_team: 1..1, summary: '1v1 games')
    end

    def initial_state
      { 'rating' => DEFAULT_RATING, 'games_played' => 0, 'pro' => false }
    end

    def score(state) = state.fetch('rating')

    def rate(standings)
      first, second = standings.sort_by(&:rank)
      first_key, first_state = first.ratings.first
      second_key, second_state = second.ratings.first
      first_score = first.rank == second.rank ? 0.5 : 1.0

      {
        first_key => play(first_state, second_state, first_score),
        second_key => play(second_state, first_state, 1.0 - first_score)
      }
    end

    private

    def play(state, opponent, actual_score)
      expected_score = 1.0 / (1.0 + (10.0**((opponent.fetch('rating').to_f - state.fetch('rating').to_f) / 400.0)))
      rating = (state.fetch('rating').to_f + (k_factor(state) * (actual_score - expected_score))).to_i

      {
        'rating' => rating,
        'games_played' => state.fetch('games_played') + 1,
        'pro' => state.fetch('pro') || rating >= PRO_RATING
      }
    end

    def k_factor(state)
      return PRO_K_FACTOR if state.fetch('pro') || state.fetch('rating') >= PRO_RATING

      state.fetch('games_played') < STARTER_GAMES ? STARTER_K_FACTOR : K_FACTOR
    end
  end
end
