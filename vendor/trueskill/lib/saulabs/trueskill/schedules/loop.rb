# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Schedules
      
      # @private
      class Loop < Base
        
        def initialize(schedule, max_delta)
          @schedule = schedule
          @max_delta = max_delta
        end
        
        def visit(depth = -1, max_depth = 0)
          iterations = 1
          delta = @schedule.visit(depth + 1, max_depth)
          while delta > @max_delta
            delta = @schedule.visit(depth + 1, max_depth)
            iterations += 1
          end
          delta
        end
        
      end
      
    end
  end
end
