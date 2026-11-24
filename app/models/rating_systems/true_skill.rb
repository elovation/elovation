# frozen_string_literal: true

module RatingSystems
  # TrueSkill for any number of teams of any size (via vendor/trueskill).
  #
  # State: { "mean" => Float, "deviation" => Float }
  # Score: the conservative estimate (mean - 3 * deviation), times 100.
  module TrueSkill
    extend self

    DEFAULT_MEAN = 25.0
    DEFAULT_DEVIATION = 25.0 / 3.0

    def key = 'trueskill'

    def name = 'TrueSkill'

    def description = 'Trueskill'

    def supported_format
      Format.new(teams: 2.., players_per_team: 1.., summary: 'two or more teams of any size')
    end

    def initial_state
      { 'mean' => DEFAULT_MEAN, 'deviation' => DEFAULT_DEVIATION }
    end

    # Truncates toward zero, matching how scores were stored historically.
    def score(state) = ((state.fetch('mean') - (3.0 * state.fetch('deviation'))) * 100).to_i

    def rate(standings)
      skills = {}
      teams_to_ranks = standings.sort_by(&:rank).to_h do |standing|
        team = standing.ratings.map do |participant, state|
          skills[participant] = Saulabs::TrueSkill::Rating.new(state.fetch('mean'), state.fetch('deviation'))
        end
        [team, standing.rank]
      end

      Saulabs::TrueSkill::FactorGraph.new(teams_to_ranks).update_skills

      skills.transform_values { |skill| { 'mean' => skill.mean, 'deviation' => skill.deviation } }
    end
  end
end
