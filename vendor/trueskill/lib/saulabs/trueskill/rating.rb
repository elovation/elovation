# -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill
    
    class Rating < Gauss::Distribution
      
      attr_accessor :activity
      attr_reader :tau, :tau_squared
      
      def initialize(mean, deviation, activity = 1.0, tau = 25/300.0)
        super(mean, deviation)
        @activity = activity
        @tau = tau
        @tau_squared = @tau**2
      end
      
      def tau=(value)
        @tau = value
        @tau_squared = value**2
      end

    end
    
  end
end
