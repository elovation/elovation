# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Factors
      
      # @private
      class Prior < Base
        
        def initialize(mean, variance, variable)
          super()
          @message = Gauss::Distribution.with_variance(mean, variance)
          bind(variable)
        end
        
        def update_message_at(index)
          raise "illegal message index: #{index}" if index < 0 || index > 0
          message = @messages[index]
          variable = @variables[index]
          new_marginal = Gauss::Distribution.with_precision(
                           variable.precision_mean + @message.precision_mean - message.precision_mean,
                           variable.precision + @message.precision - message.precision
                         )
          diff = variable - new_marginal
          variable.replace(new_marginal)
          message.replace(@message)
          return diff
        end
        
        def log_normalization
          0.0
        end
        
      end
      
    end
  end
end
