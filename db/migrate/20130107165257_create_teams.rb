class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.integer :rank
      t.references :result

      t.timestamps
    end

    create_table :players_teams do |t|
      t.references :player
      t.references :team
    end
  end

  def down
    drop_table :teams
    drop_table :players_teams
  end
end
