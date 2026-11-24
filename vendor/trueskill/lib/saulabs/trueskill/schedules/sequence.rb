# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Schedules
      
      # @private
      class Sequence < Base
        
        def initialize(schedules)
          @schedules = schedules
        end
        
        def visit(depth = -1, max_depth = 0)
          max_delta = 0
          @schedules.each do |schedule|
            max_delta = [schedule.visit(depth + 1, max_depth), max_delta].max
          end
          max_delta
        end
        
      end
      
    end
  end
end
