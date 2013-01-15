class AddTrueskillMeanAndDeviationToRating < ActiveRecord::Migration
  def change
    change_table :ratings do |t|
      t.float :trueskill_mean
      t.float :trueskill_deviation
    end

    change_table :rating_history_events do |t|
      t.float :trueskill_mean
      t.float :trueskill_deviation
    end
  end
end
