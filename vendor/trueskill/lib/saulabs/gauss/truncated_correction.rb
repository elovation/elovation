# -*- encoding : utf-8 -*-
module Saulabs
  module Gauss
    class TruncatedCorrection
  
      class << self
        
        def w_within_margin(perf_diff, draw_margin)
          abs_diff = perf_diff.abs
          denom = Distribution.cdf(draw_margin - abs_diff) - Distribution.cdf(-draw_margin - abs_diff)
          return 1.0 if denom < 2.2e-162
          vt = v_within_margin(abs_diff, draw_margin)
          return vt**2 + (
                          (draw_margin - abs_diff) * 
                          Gauss::Distribution.standard.value_at(draw_margin - abs_diff) -
                          (-draw_margin - abs_diff) *
                          Gauss::Distribution.standard.value_at(-draw_margin - abs_diff) 
                         ) / denom
        end
        
        def v_within_margin(perf_diff, draw_margin)
          abs_diff = perf_diff.abs
          denom = Distribution.cdf(draw_margin - abs_diff) - Distribution.cdf(-draw_margin - abs_diff)
          if denom < 2.2e-162
            return perf_diff < 0 ? -perf_diff - draw_margin : -perf_diff + draw_margin
          end
          num = Gauss::Distribution.standard.value_at(-draw_margin - abs_diff) -
                Gauss::Distribution.standard.value_at(draw_margin - abs_diff)
          perf_diff < 0 ? -num/denom : num/denom
        end
        
        def w_exceeds_margin(perf_diff, draw_margin)
          denom = Distribution.cdf(perf_diff - draw_margin)
          if denom < 2.2e-162
            return perf_diff < 0.0 ? 1.0 : 0.0
          else
            v = v_exceeds_margin(perf_diff, draw_margin)
            return v * (v + perf_diff - draw_margin)
          end
        end
  
        def v_exceeds_margin(perf_diff, draw_margin)
          denom = Distribution.cdf(perf_diff - draw_margin)
          denom < 2.2e-162 ? -perf_diff + draw_margin : Gauss::Distribution.standard.value_at(perf_diff - draw_margin)/denom 
        end
  
        def exceeds_margin(perf_diff, draw_margin)
          abs_diff = perf_diff.abs
          denom = Distribution.cdf(draw_margin - abs_diff) - Distribution.cdf(-draw_margin - abs_diff)
          if denom < 2.2e-162
            return 1.0
          else
            v = v_exceeds_margin(abs_diff, draw_margin)
            return v**2 + 
                   ((draw_margin - abs_diff) * Gauss::Distribution.standard.value_at(draw_margin - abs_diff) -
                   (-draw_margin - abs_diff) * Gauss::Distribution.standard.value_at(-draw_margin - abs_diff)) / denom
          end
        end
  
      end
    end
  end
end
