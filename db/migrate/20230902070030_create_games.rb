class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.string :rating_type
      t.integer :min_number_of_teams
      t.integer :max_number_of_teams
      t.integer :min_number_of_players_per_team
      t.integer :max_number_of_players_per_team
      t.boolean :allow_ties

      t.timestamps
    end
  end
end
