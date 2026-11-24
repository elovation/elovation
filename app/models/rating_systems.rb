# frozen_string_literal: true

# Rating systems turn the outcome of one result into new rating states.
#
# Every rating system is a pure module with the same interface:
#
#   key              -> String stored in games.rating_type, e.g. "elo"
#   name             -> String, e.g. "Elo"
#   description      -> String shown to people choosing a rating system
#   supported_format -> Format: the results it can rate (teams, players per team)
#   initial_state    -> Hash: the rating state of a player before any results
#   score(state)     -> Integer: the display value for a state (leaderboards sort by it)
#   rate(standings)  -> Hash: { participant => new state } for every participant
#
# `rate` is only ever given results within `supported_format`. Every rating
# system supports at least two teams of one player.
#
# A state is a Hash with String keys that only its rating system reads or
# writes. States must survive a round trip through JSON.
#
# `rate` takes Standings: one per team, each with the team's rank (lower is
# better; equal ranks are a tie) and the prior state of each participant.
# Participants are opaque keys (the app uses player ids). Rating systems never
# touch the database; loading and saving ratings is the caller's job.
#
# To run a rating system over a series of results, use RatingSystems::Replay.
module RatingSystems
  # One team in one result: its rank and each participant's prior state.
  Standing = Data.define(:rank, :ratings)

  # One team in one result: its rank and its participants (for Replay).
  Placing = Data.define(:rank, :participants)

  # The results a rating system can rate: how many teams, and how many players
  # per team (Ranges; an endless Range has no maximum). `summary` completes the
  # sentence "<name> can only be used with ...".
  Format = Data.define(:teams, :players_per_team, :summary) do
    # Whether every result the game allows falls within this format.
    def supports?(game)
      within?(teams, game.min_number_of_teams, game.max_number_of_teams) &&
        within?(players_per_team, game.min_number_of_players_per_team, game.max_number_of_players_per_team)
    end

    # The only number of teams allowed, if there is exactly one.
    def fixed_teams = fixed(teams)

    # The only number of players per team allowed, if there is exactly one.
    def fixed_players_per_team = fixed(players_per_team)

    private

    def within?(range, min, max)
      return false if min.nil?

      range.cover?(min) && (max.nil? ? range.end.nil? : range.cover?(max))
    end

    def fixed(range) = (range.begin if range.begin == range.end)
  end

  def self.all
    [Elo, TrueSkill]
  end

  def self.keys
    all.map(&:key)
  end

  def self.fetch(key)
    all.find { |system| system.key == key }
  end
end
