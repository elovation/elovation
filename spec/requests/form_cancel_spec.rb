require "rails_helper"

# Regression: Cancel was a button_to inside the edit form. Browsers drop a
# nested form, so the button submitted the outer form and saved the edits.
RSpec.describe "Cancelling a form", type: :request do
  {
    "editing a player" => -> { edit_player_path(FactoryBot.create(:player)) },
    "adding a player" => -> { new_player_path },
    "editing a game" => -> { edit_game_path(FactoryBot.create(:trueskill_game)) }
  }.each do |form, path|
    it "is a link that leaves the form without submitting it, when #{form}" do
      get instance_exec(&path)

      expect(response.body.scan("<form").size).to eq(1)
      expect(response.body).to match(%r{<a [^>]*>Cancel</a>})
    end
  end
end
