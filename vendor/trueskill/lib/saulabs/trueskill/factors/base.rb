# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    
    # @private
    module Factors
      
      # @private
      class Base
        
        def initialize
          @messages = []
          @bindings = {}
          @variables = []
          @priors = []
        end
        
        def update_message_at(index)
          raise "Abstract method Factors::Base#update_message_at(index) called"
        end
        
        def message_count
          @messages.size
        end
        
        def log_normalization
          raise "Abstract method Factors::Base#log_normalization called"
        end
        
        def reset_marginals
          @bindings.values.each { |var| var.replace(Gauss::Distribution.new) }
        end
        
        def send_message_at(idx)
          message = @messages[idx]
          variable = @variables[idx]
          log_z = Gauss::Distribution.log_product_normalization(message, variable)
          variable.replace(message * variable)
          return log_z
        end
        
        def bind(variable)
          message = Gauss::Distribution.new
          @messages << message
          @bindings[message] = variable
          @variables << variable
          return message
        end
        
      end
      
    end
  end
end
