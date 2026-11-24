# frozen_string_literal: true

module RatingSystems
  # Runs a rating system over results in order, entirely in memory.
  #
  #   replay = RatingSystems::Replay.new(RatingSystems::Elo)
  #   results.each { |placings| replay.play(placings) }
  #   replay.scores # => { participant => score }
  #
  # Participants start from the system's initial state unless prior states are
  # given. Any rating system can replay any series of results it can rate.
  class Replay
    attr_reader :system, :states

    def initialize(system, states = {})
      @system = system
      @states = states.dup
    end

    # Rates one result and returns the new state of each of its participants.
    def play(placings)
      standings = placings.map do |placing|
        ratings = placing.participants.to_h { |participant| [participant, state_of(participant)] }
        Standing.new(rank: placing.rank, ratings: ratings)
      end

      system.rate(standings).tap { |new_states| @states.merge!(new_states) }
    end

    def state_of(participant)
      @states.fetch(participant) { system.initial_state }
    end

    def scores
      @states.transform_values { |state| system.score(state) }
    end
  end
end
