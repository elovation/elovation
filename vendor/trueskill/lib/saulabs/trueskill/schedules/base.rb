# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Schedules
      
      # @private
      class Base
        
        def visit(depth = -1, max_depth = 0)
          raise "Abstract method Schedules::Base#visit(depth, max_depth) called"
        end
        
      end
      
    end
  end
end
