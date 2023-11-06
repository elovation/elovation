class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table(:ratings) do |t|
      t.references(
        :game,
        null: false,
        foreign_key: true,
        index: {
          name: "index_ratings_on_game_id"
        }
      )
      t.references(
        :player,
        null: false,
        foreign_key: true,
        index: {
          name: "index_ratings_on_player_id"
        }
      )
      t.integer(:value, null: false)
      t.boolean(:pro, null: false)
      t.float(:trueskill_mean)
      t.float(:trueskill_deviation)

      t.timestamps
    end
  end
end
