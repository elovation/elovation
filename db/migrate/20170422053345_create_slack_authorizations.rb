class CreateSlackAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :slack_authorizations do |t|
      t.string :access_token
      t.string :scope
      t.string :user_id
      t.string :team_name
      t.string :team_id, index: true
    end
  end
end
