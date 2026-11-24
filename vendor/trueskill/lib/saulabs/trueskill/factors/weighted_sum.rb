# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Factors
      
      # @private
      class WeightedSum < Base
        
        attr_reader :weights, :weights_squared, :index_order
        
        def initialize(variable, ratings, weights)
          super()
          @weights = [weights]
          @weights_squared = [@weights.first.map { |w| w**2 }]
          @index_order = [(0..weights.size+1).to_a]
          (1..weights.size).each do |idx|
            dest_idx = 0
            @weights[idx] = []
            @weights_squared[idx] = []
            @index_order << [idx]
            (0..ratings.size-1).each do |src_idx|
              next if src_idx == idx-1
              weight = weights[idx-1] == 0 ? 0.0 : -weights[src_idx] / weights[idx-1]
              @weights[idx][dest_idx] = weight
              @weights_squared[idx][dest_idx] = weight**2
              @index_order.last[dest_idx+1] = src_idx+1
              dest_idx += 1
            end
            final_weight = weights[idx-1] == 0 ? 0.0 : 1.0 / weights[idx-1]
            @weights[idx][dest_idx] = final_weight
            @weights_squared[idx][dest_idx] = final_weight**2
            @index_order.last[weights.size] = 0
          end
          bind(variable)
          ratings.each { |v| bind(v) }
        end
        
        def update_message_at(index)
          raise "illegal message index: #{index}" if index < 0 || index >= @messages.count
          indices = @index_order[index]
          updated_messages = []
          updated_variables = []
          @messages.each_index do |i|
            updated_messages << @messages[indices[i]]
            updated_variables << @variables[indices[i]]
          end
          update_helper(@weights[index], @weights_squared[index], updated_messages, updated_variables)
        end
        
        def log_normalization
          res = 0
          (1..@variables.size-1).each do |i|
            res += Gauss::Distribution.log_ratio_normalization(@variables[i], @messages[i])
          end
          res
        end
        
      private
        
        def update_helper(weights, weights_squared, messages, variables)
          marginal0 = variables[0].clone
          ips, wms = 0.0, 0.0
          weights_squared.each_index do |i|
            ips += weights_squared[i] / (variables[i+1].precision - messages[i+1].precision)
            diff = variables[i+1] / messages[i+1]
            wms += weights[i] * (variables[i+1].precision_mean - messages[i+1].precision_mean) / (variables[i+1].precision - messages[i+1].precision)
          end
          new_message = Gauss::Distribution.with_precision(1.0/ips*wms, 1.0/ips)
          old_marginal = marginal0 / messages[0]
          new_marginal = old_marginal * new_message
          messages[0].replace(new_message)
          variables[0].replace(new_marginal)
          return new_marginal - marginal0
        end
        
      end
      
    end
  end
end
