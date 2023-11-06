class CreateRatingHistoryEvents < ActiveRecord::Migration[7.0]
  def change
    create_table(:rating_history_events) do |t|
      t.references(
        :rating,
        null: false,
        foreign_key: true,
        index: {
          name: "index_rating_history_events_on_rating_id"
        }
      )
      t.integer(:value, null: false)
      t.float(:trueskill_mean)
      t.float(:trueskill_deviation)

      t.timestamps
    end
  end
end
