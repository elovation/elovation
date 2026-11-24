# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill

    class FactorGraph

      # @return [Array<Array<TrueSkill::Rating>>]
      attr_reader :teams

      # @return [Float]
      attr_reader :beta

      # @return [Float]
      attr_reader :beta_squared

      # @return [Float]
      attr_reader :draw_probability

      # @return [Float]
      attr_reader :epsilon

      # @private
      attr_reader :layers

      # @return [Boolean]
      attr_reader :skills_additive


      # Creates a new trueskill factor graph for calculating the new skills based on the given game parameters
      #
      # @param [Array<Array<TrueSkill::Rating>>] teams
      #   player-ratings grouped in Arrays by teams
      # @param [Array<Integer>] ranks
      #   team rankings, example: [2,1,3] first team  in teams finished 2nd, second team 1st and third team 3rd
      # @param [Hash] options
      #   the options hash to configure the factor graph constants beta, draw_probability and skills_additive
      #
      # @option options [Float] :beta (4.166667)
      #   the length of the skill-chain. Use a low value for games with a small amount of chance (Go, Chess, etc.) and
      #   a high value for games with a high amount of chance (Uno, Bridge, etc.)
      # @option options [Float] :draw_probability (0.1)
      #   how probable is a draw in the game outcome [0.0,1.0]
      # @option options [Boolean] :skills_additive (true)
      #   true is valid for games like Halo etc, where skill is additive (2 players are better than 1),
      #   false for card games like Skat, Doppelkopf, Bridge where skills are not additive,
      #         two players dont make the team stronger, skills averaged)
      #
      # @example Calculating new skills of a two team game, where one team has one player and the other two
      #
      #  require 'rubygems'
      #  require 'saulabs/trueskill'
      #
      #  include Saulabs::TrueSkill
      #
      #  # team 1 has just one player with a mean skill of 27.1, a skill-deviation of 2.13
      #  # and a play activity of 100 %
      #  team1 = [Rating.new(27.1, 2.13, 1.0)]
      #
      #  # team 2 has two players
      #  team2 = [Rating.new(22.0, 0.98, 0.8), Rating.new(31.1, 5.33, 0.9)]
      #
      #  # team 1 finished first and team 2 second
      #  graph = FactorGraph.new( team1 => 1, team2 => 2 )
      #
      #  # update the Ratings
      #  graph.update_skills
      #
      def initialize(ranks_teams_hash, options = {})
        @teams = ranks_teams_hash.keys
        @ranks = ranks_teams_hash.values

        opts = {
            :beta => 25/6.0,
            :draw_probability => 0.1,
            :skills_additive => true
          }.merge(options)

        @beta = opts[:beta]
        @draw_probability = opts[:draw_probability]
        @beta_squared = @beta**2
        @epsilon = -Math.sqrt(2.0 * @beta_squared) * Gauss::Distribution.inv_cdf((1.0 - @draw_probability) / 2.0)
        @skills_additive = opts[:skills_additive]

        @prior_layer = Layers::PriorToSkills.new(self, @teams)
        @layers = [
          @prior_layer,
          Layers::SkillsToPerformances.new(self),
          Layers::PerformancesToTeamPerformances.new(self, @skills_additive),
          Layers::IteratedTeamPerformances.new(self,
            Layers::TeamPerformanceDifferences.new(self),
            Layers::TeamDifferenceComparision.new(self, @ranks)
          )
        ]
      end

      def draw_margin
        Gauss::Distribution.inv_cdf(0.5*(@draw_probability + 1)) * Math.sqrt(1 + 1) * @beta
      end

      # Updates the skills of the players inplace
      #
      # @return [Float] the probability of the games outcome
      def update_skills
        #puts " vorher = #{@layers.map(&:input).inspect}}"
        build_layers
        run_schedule
        @teams.each_with_index do |team, i|
          team.each_with_index do |player, j|
            player.replace(@prior_layer.output[i][j])
          end
        end
        ranking_probability

      end

    private

      def ranking_probability
        # factor_list = []
        # sum_log_z, sum_log_s = 0.0
        # @layers.each do |layer|
        #   layer.factors.each do |factor|
        #     factor.reset_marginals
        #     factor.messages.each_index { |i| sum_log_z += factor.send_message_at(i) }
        #     sum_log_s += factor.log_normalization
        #   end
        # end
        # Math.exp(sum_log_z + sum_log_s)
        0.0
      end

      def updated_skills
        @prior_layer.output
      end

      def build_layers
        output = nil
        @layers.each do |layer|
          layer.input = output
          layer.build
          output = layer.output

        end
      end

      def run_schedule
        schedules = @layers.map(&:prior_schedule) + @layers.reverse.map(&:posterior_schedule)
        Schedules::Sequence.new(schedules.compact).visit
      end

    end

  end
end
