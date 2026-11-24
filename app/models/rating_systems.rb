# frozen_string_literal: true

# Rating systems turn the outcome of one result into new rating states.
#
# Every rating system is a pure module with the same interface:
#
#   key            -> String stored in games.rating_type, e.g. "elo"
#   description    -> String shown to people choosing a rating system
#   initial_state  -> Hash: the rating state of a player before any results
#   score(state)   -> Integer: the display value for a state (leaderboards sort by it)
#   rate(standings)-> Hash: { participant => new state } for every participant
#   validate_game(game) -> adds errors to a Game whose format the system can't rate
#
# A state is a Hash with String keys that only its rating system reads or
# writes. States must survive a round trip through JSON.
#
# `rate` takes Standings: one per team, each with the team's rank (lower is
# better; equal ranks are a tie) and the prior state of each participant.
# Participants are opaque keys (the app uses player ids). Rating systems never
# touch the database; loading and saving ratings is the caller's job.
module RatingSystems
  Standing = Data.define(:rank, :ratings)

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
