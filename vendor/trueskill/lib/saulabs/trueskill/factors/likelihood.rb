# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Factors
      
      # @private
      class Likelihood < Base
        
        def initialize(beta_squared, variable1, variable2)
          super()
          @precision = 1.0 / beta_squared
          bind(variable1)
          bind(variable2)
        end
        
        def update_message_at(index)
          case index
          when 0 then update_helper(@messages[0], @messages[1], @variables[0], @variables[1])
          when 1 then update_helper(@messages[1], @messages[0], @variables[1], @variables[0])
          else
            raise "illegal message index: #{index}"
          end
        end
        
        def log_normalization
          Gauss::Distribution.log_ratio_normalization(@variables[0], @messages[0])
        end
      
      private
        
        def update_helper(message1, message2, variable1, variable2)
          a = @precision / (@precision + variable2.precision - message2.precision)
          new_message = Gauss::Distribution.with_precision(
                          a * (variable2.precision_mean - message2.precision_mean),
                          a * (variable2.precision - message2.precision)
                        )
          new_marginal = (variable1 / message1) * new_message
          diff = new_marginal - variable1
          message1.replace(new_message)
          variable1.replace(new_marginal)
          return diff
        end
        
      end
      
    end
  end
end
