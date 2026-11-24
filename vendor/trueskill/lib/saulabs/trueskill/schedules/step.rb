# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Schedules
      
      # @private
      class Step < Base
        
        def initialize(factor, index)
          @factor = factor
          @index = index
        end
        
        def visit(depth = -1, max_depth = 0)
          @factor.update_message_at(@index)
        end          
        
      end
      
    end
  end
end
