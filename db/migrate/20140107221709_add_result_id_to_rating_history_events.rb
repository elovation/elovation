class AddResultIdToRatingHistoryEvents < ActiveRecord::Migration
  def change
    add_column :rating_history_events, :result_id, :integer
    add_column :rating_history_events, :change, :integer
  end
end
