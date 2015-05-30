class RemoveCurrentRating < ActiveRecord::Migration
  def change
    drop_table :current_rating
  end
end
