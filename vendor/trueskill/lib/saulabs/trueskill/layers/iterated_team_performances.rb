# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Layers
      
      # @private
      class IteratedTeamPerformances < Base
        
        def initialize(graph, team_perf_diff, team_diff_comp)
          super(graph)
          @tpd = team_perf_diff
          @tdc = team_diff_comp
        end
        
        def build
          @tpd.input = @input
          @tpd.build
          @tdc.input = @tpd.output
          @tdc.build
        end
        
        def factors
          @tpd.factors + @tdc.factors
        end
        
        def prior_schedule
          loop_schedule = if @input.size == 2
            two_team_loop_schedule
          elsif @input.size > 2
            multiple_team_loop_schedule
          else
            raise 'Illegal input'
          end
          team_diffs = @tpd.factors.size;
          Schedules::Sequence.new([loop_schedule, 
                                   Schedules::Step.new(@tpd.factors[0], 1),
                                   Schedules::Step.new(@tpd.factors[team_diffs-1], 2)])
        end
        
        private 
        
        def two_team_loop_schedule
          Schedules::Sequence.new([
            Schedules::Step.new(@tpd.factors[0], 0), 
            Schedules::Step.new(@tdc.factors[0], 0)
          ])
        end
        
        def multiple_team_loop_schedule
          team_diff = @tpd.factors.size
          forward_schedule = Schedules::Sequence.new(
                               (0..team_diff-2).map { |i|
                                 Schedules::Sequence.new([
                                   Schedules::Step.new(@tpd.factors[i], 0),
                                   Schedules::Step.new(@tdc.factors[i], 0),
                                   Schedules::Step.new(@tpd.factors[i], 2)
                                 ])
                               })
          backward_schedule = Schedules::Sequence.new(
                                (0..team_diff-2).map { |i|
                                  Schedules::Sequence.new([
                                    Schedules::Step.new(@tpd.factors[team_diff-1-i], 0),
                                    Schedules::Step.new(@tdc.factors[team_diff-1-i], 0),
                                    Schedules::Step.new(@tpd.factors[team_diff-1-i], 1)
                                  ])
                                })
          Schedules::Loop.new(Schedules::Sequence.new([forward_schedule, backward_schedule]), 0.0001)
        end
        
      end
      
    end
  end
end
