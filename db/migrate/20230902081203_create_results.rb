class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table(:results) do |t|
      t.references(
        :game,
        null: false,
        foreign_key: true,
        index: {
          name: "index_results_on_game_id"
        }
      )

      t.timestamps
    end
  end
end
