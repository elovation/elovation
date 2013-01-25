class Release006 < ActiveRecord::Migration
  class Result < ActiveRecord::Base
    has_many :teams
  end

  class Team < ActiveRecord::Base
    belongs_to :result
    has_and_belongs_to_many :players
  end

  class Game < ActiveRecord::Base; end

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

    ActiveRecord::Base.connection.transaction do
      Result.all.each do |result|
        result.teams.build rank: 1, player_ids: [result.winner_id]
        result.teams.build rank: 2, player_ids: [result.loser_id]
        result.save!
      end
    end

    remove_column :results, :winner_id
    remove_column :results, :loser_id
    drop_table :players_results

    change_table :games do |t|
      t.string :rating_type
      t.integer :min_number_of_teams
      t.integer :max_number_of_teams
      t.integer :min_number_of_players_per_team
      t.integer :max_number_of_players_per_team
      t.boolean :allow_ties
    end

    Game.update_all(
      rating_type: "elo",
      min_number_of_teams: 2,
      max_number_of_teams: 2,
      min_number_of_players_per_team: 1,
      max_number_of_players_per_team: 1,
      allow_ties: false
    )

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
