class AddScoreToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :score, :integer
  end
end
