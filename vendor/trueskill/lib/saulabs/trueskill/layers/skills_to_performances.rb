# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Layers
      
      # @private
      class SkillsToPerformances < Base
        
        def build
          @input.each do |team|
            team_performances = []
            team.each do |rating|
              variable = TrueSkill::Rating.new(0.0, 0.0, rating.activity, rating.tau)
              @factors << Factors::Likelihood.new(@graph.beta_squared, variable, rating)
              team_performances << variable
            end
            @output << team_performances
          end
        end
        
        def prior_schedule
          Schedules::Sequence.new(@factors.map { |f| Schedules::Step.new(f, 0) })
        end
        
        def posterior_schedule
          Schedules::Sequence.new(@factors.map { |f| Schedules::Step.new(f, 1) })
        end
        
      end
    
    end
  end
end
