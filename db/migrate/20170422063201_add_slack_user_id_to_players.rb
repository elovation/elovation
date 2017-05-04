class AddSlackUserIdToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :slack_id, :string
  end
end
