class AddInformationToGame < ActiveRecord::Migration
  class Game < ActiveRecord::Base; end
  def change
    change_table :games do |t|
      t.string :rating_type
      t.integer :min_number_of_teams
      t.integer :max_number_of_teams
      t.integer :min_number_of_players_per_team
      t.integer :max_number_of_players_per_team
      t.boolean :allow_ties
    end
    Game.update_all rating_type: "elo",
                    min_number_of_teams: 2,
                    max_number_of_teams: 2,
                    min_number_of_players_per_team: 1,
                    max_number_of_players_per_team: 1,
                    allow_ties: false
  end
end
