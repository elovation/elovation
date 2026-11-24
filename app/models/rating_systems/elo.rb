# frozen_string_literal: true

module RatingSystems
  # Elo for one-on-one games, with FIDE K-factors.
  #
  # State: { "rating" => Integer, "games_played" => Integer, "pro" => Boolean }
  #
  # Reproduces the elo gem (0.1.0) this replaced, exactly, so existing ratings
  # and rebuilds are unchanged:
  # - New ratings are truncated toward zero.
  # - K is 10 for a pro (a player who has ever reached 2400) or anyone rated
  #   2400+, otherwise 25 for a starter (fewer than 30 games), otherwise 15.
  # - Quirk: for the first-placed player (in a draw, the first-listed one), the
  #   games-played count used to decide whether they are a starter already
  #   includes the game being rated, so they stop being a starter one game early.
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
      # Stable: in a draw the first-listed standing stays first (see the quirk above).
      first, second = standings.each_with_index.sort_by { |standing, index| [standing.rank, index] }.map(&:first)
      first_key, first_state = first.ratings.first
      second_key, second_state = second.ratings.first
      first_score = first.rank == second.rank ? 0.5 : 1.0

      {
        first_key => play(first_state, second_state, first_score, first_placed: true),
        second_key => play(second_state, first_state, 1.0 - first_score, first_placed: false)
      }
    end

    private

    def play(state, opponent, actual_score, first_placed:)
      expected_score = 1.0 / (1.0 + (10.0**((opponent.fetch('rating').to_f - state.fetch('rating').to_f) / 400.0)))
      rating = (state.fetch('rating').to_f + (k_factor(state, first_placed:) * (actual_score - expected_score))).to_i

      {
        'rating' => rating,
        'games_played' => state.fetch('games_played') + 1,
        'pro' => state.fetch('pro') || rating >= PRO_RATING
      }
    end

    def k_factor(state, first_placed:)
      return PRO_K_FACTOR if state.fetch('pro') || state.fetch('rating') >= PRO_RATING

      games_played = state.fetch('games_played') + (first_placed ? 1 : 0)
      games_played < STARTER_GAMES ? STARTER_K_FACTOR : K_FACTOR
    end
  end
end
