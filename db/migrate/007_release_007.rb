class Release007 < ActiveRecord::Migration
  class Rating < ActiveRecord::Base
  end

  def up
    transaction do
      Rating.where("trueskill_mean is not null and trueskill_deviation is not null").each do |rating|
        new_value = (rating.trueskill_mean - (3.0 * rating.trueskill_deviation)) * 100
        rating.update_attribute :value, new_value
      end
    end
  end
end
