# frozen_string_literal: true

module RatingSystems
  # Elo for one-on-one games, using FIDE K-factors (via the elo gem).
  #
  # State: { "rating" => Integer, "games_played" => Integer, "pro" => Boolean }
  module Elo
    extend self

    DEFAULT_RATING = 1000

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

      first_elo = to_elo(first_state)
      second_elo = to_elo(second_state)

      if first.rank == second.rank
        first_elo.plays_draw(second_elo)
      else
        first_elo.wins_from(second_elo)
      end

      { first_key => from_elo(first_elo), second_key => from_elo(second_elo) }
    end

    private

    def to_elo(state)
      ::Elo::Player.new(rating: state.fetch('rating'), games_played: state.fetch('games_played'), pro: state.fetch('pro'))
    end

    def from_elo(elo)
      { 'rating' => elo.rating, 'games_played' => elo.games_played, 'pro' => elo.pro? }
    end
  end
end
