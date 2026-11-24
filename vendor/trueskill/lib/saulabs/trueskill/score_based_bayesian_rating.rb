# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill

    class ScoreBasedBayesianRating

      # @return [Array<Array<TrueSkill::Rating>>]
      attr_reader :teams

      # @return [Float]
      attr_reader :beta

      # @return [Float]
      attr_reader :beta_squared

      # @return [Float]
      attr_reader :gamma

      # @return [Float]
      attr_reader :gamma_squared


      # @return [Boolean]
      attr_reader :skills_additive





      # Creates a new skill estimate for given scores and team configuration based on the given game parameters
      # Works for the special case: two teams
      #
      # @param [{ Array<TrueSkill::Rating>, Array<TrueSkill::Rating> }] teams
      #   player-ratings grouped in Arrays by teams
      #
      # @option options [Float] :beta (4.166667)
      #   the length of the skill-chain. Use a low value for games with a small amount of chance (Go, Chess, etc.) and
      #   a high value for games with a high amount of chance (Uno, Bridge, etc.)
      # @option options [Float] :gamma
      #   variance of score distribution. should be extracted from user data. For games with few scoring events (Soccer, etc)
      #   gamma is small, for games with many scoring events (Shooter, etc), gamma is large
      # @param [Float] score
      #   scores obtained by the respective teams s = s1 - s2 (can be negative)
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
      #  # team 1 got 10.0 points and team 2 3.0
      #  graph = FactorGraph.new( team1 => 10.0, team2 => 3.0 )
      #
      #  # update the Ratings
      #  graph.update_skills

    def initialize(score_teams_hash, options = {})
      @teams  = score_teams_hash.keys
      @scores = score_teams_hash.values
      raise "teams.size should be 2: this implementation of the score based bayesian rating only works for two teams" unless @teams.size == 2

      opts = {
            :beta => 25/6.0,
            :skills_additive => true
            }.merge(options)
      @beta = opts[:beta]
      @beta_squared = @beta**2

      @skills_additive = opts[:skills_additive]

      @gamma = options[:gamma] || 0.1
      @gamma_squared = @gamma * @gamma

      @teams = teams

    end

    def update_skills
        #game can be 1vs1, 1vs2, 1vs3 or 2vs2
        #

        #team1 vs team2
        # if @skills_additive = true: no averaging of skills and variance
        # otherwise: mean and skill_deviation averaged over team sizes
        n_team_1    = @skills_additive ? 1 : @teams[0].size.to_f
        n_team_2    = @skills_additive ? 1 : @teams[1].size.to_f

        n_all       = @teams[0].size.to_f + @teams[1].size.to_f
        var_team_1  = @teams[0].inject(0){|sum,item| sum + item.variance}
        var_team_2  = @teams[1].inject(0){|sum,item| sum + item.variance}
        mean_team_1 = @teams[0].inject(0){|sum,item| sum + item.mean}
        mean_team_2 = @teams[1].inject(0){|sum,item| sum + item.mean}




        @teams[0].map!{|rating|
          precision = 1.0 / rating.variance + 1.0/ ( n_all * @beta_squared + 2.0 * @gamma_squared + var_team_2 / n_team_2 + var_team_1 / n_team_1 - rating.variance / n_team_1)
          precision_mean = rating.mean / rating.variance + (@scores[0] - @scores[1] + n_team_1 * (mean_team_2 / n_team_2 - mean_team_1 / n_team_1 + rating.mean / n_team_1)) / ( n_all * @beta_squared + 2.0 * @gamma_squared + var_team_2 / n_team_2 + var_team_1 / n_team_1 - rating.variance / n_team_1)
          partial_updated_precision = rating.precision + rating.activity*( precision - rating.precision)
          partial_updated_precision_mean =  rating.precision_mean + rating.activity * (precision_mean - rating.precision_mean)
          Rating.new(partial_updated_precision_mean / partial_updated_precision, ( 1.0 / partial_updated_precision + rating.tau_squared)**0.5, rating.activity, rating.tau)
        }
        @teams[1].map!{|rating|
          precision = 1.0 / rating.variance + 1.0 / (n_all*@beta_squared + 2.0 * @gamma_squared + var_team_1 / n_team_1 + var_team_2 / n_team_2 - rating.variance / n_team_2)
          precision_mean = rating.mean / rating.variance + (@scores[1] - @scores[0] + n_team_2 * (mean_team_1 / n_team_1 - mean_team_2 / n_team_2 + rating.mean / n_team_2)) / ( n_all * @beta_squared + 2.0 * @gamma_squared + var_team_1 / n_team_1 + var_team_2/n_team_2 - rating.variance / n_team_2)
          partial_updated_precision = rating.precision + rating.activity*( precision - rating.precision)
          partial_updated_precision_mean =  rating.precision_mean + rating.activity * (precision_mean - rating.precision_mean)
          Rating.new(partial_updated_precision_mean / partial_updated_precision, (1.0 / partial_updated_precision + rating.tau_squared)**0.5, rating.activity, rating.tau)
        }




      end
    end
  end
end
