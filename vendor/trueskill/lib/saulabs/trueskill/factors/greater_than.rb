# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Factors
      
      # @private
      class GreaterThan < Base
        
        def initialize(epsilon, variable)
          super()
          @epsilon = epsilon
          bind(variable) 
        end
        
        def log_normalization
          msg = @variables[0] / @messages[0]
          -Gauss::Distribution.log_product_normalization(msg, @messages[0]) + 
           Math.log(Gauss::Distribution.cdf((msg.mean - @epsilon) / msg.deviation))
        end
        
        def update_message_at(index)
          raise "illegal message index: #{index}" if index < 0 || index > 0
          message = @messages[index]
          variable = @bindings[@messages[index]]
          
          msg = variable / message
          c = msg.precision
          d = msg.precision_mean
          sqrt_c = Math.sqrt(c)
          d_sqrt_c = sqrt_c == 0 ? 0.0 : d / sqrt_c 
          e_sqrt_c = @epsilon * sqrt_c
          denom = 1.0 - Gauss::TruncatedCorrection.w_exceeds_margin(d_sqrt_c, e_sqrt_c)
          new_precision = c / denom
          new_precision_mean = (d + sqrt_c * Gauss::TruncatedCorrection.v_exceeds_margin(d_sqrt_c, e_sqrt_c)) / denom
          new_marginal = Gauss::Distribution.with_precision(new_precision_mean, new_precision)
          new_message = message * new_marginal / variable
          diff = new_marginal - variable
          message.replace(new_message)
          variable.replace(new_marginal)
          return diff
        end
        
      end
      
    end
  end
end
