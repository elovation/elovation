# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Layers
      
      # @private
      class PerformancesToTeamPerformances < Base
        
        def initialize(graph, skills_additive = true)
          @skills_additive = skills_additive
          super graph
        end

        def build
          @input.each do |ratings|
            variable = Gauss::Distribution.new
            activities = ratings.map(&:activity)
            activities.map!{|a| a / ratings.size.to_f} unless @skills_additive
            @factors << Factors::WeightedSum.new(variable, ratings,  activities)
            @output << [variable]
          end
        end
        
        def prior_schedule
          Schedules::Sequence.new(@factors.map { |f| Schedules::Step.new(f, 0) })
        end
        
        def posterior_schedule
          steps = []
          @factors.each do |f|
            (1..f.message_count-1).each { |i| steps << Schedules::Step.new(f, i) }
          end
          Schedules::Sequence.new(steps)
        end
        
      end
    
    end
  end
end
