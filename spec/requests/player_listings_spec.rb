require "rails_helper"

# Regression: listing a player who hasn't played yet raised NoMethodError
# (player.ratings.last was nil), so the home page and players page returned 500.
RSpec.describe "Player listings", type: :request do
  let!(:regular) { FactoryBot.create(:rating, player: FactoryBot.create(:player, name: "Regular")).player }
  let!(:newcomer) { FactoryBot.create(:player, name: "Newcomer") }

  it "shows the home page when a player hasn't played yet" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Newcomer")
  end

  it "shows the players page when a player hasn't played yet" do
    get players_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Newcomer")
  end
end
