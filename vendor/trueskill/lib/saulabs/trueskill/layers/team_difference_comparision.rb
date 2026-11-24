# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    # @private
    module Layers
      
      # @private
      class TeamDifferenceComparision < Base
        
        def initialize(graph, ranks)
          super(graph)
          @ranks = ranks
          @epsilon = graph.draw_margin
        end
        
        def build
          (0..@input.size-1).each do |i|
            if @ranks[i] == @ranks[i+1]
              @factors << Factors::Within.new(@epsilon, @input[i][0])
            else
              @factors << Factors::GreaterThan.new(@epsilon, @input[i][0])
            end
          end
        end
        
      end
      
    end
  end
end
