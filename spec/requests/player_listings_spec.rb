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

  # A player's latest rating could be from any game, mixing Elo and TrueSkill
  # numbers, so the listings don't show one.
  it "doesn't show a rating from an arbitrary game next to each player" do
    FactoryBot.create(:rating, player: regular, value: 4321)

    get root_path
    expect(response.body).not_to include("4321")

    get players_path
    expect(response.body).not_to include("4321")
  end

  it "doesn't show players' email addresses" do
    regular.update!(email: "regular@example.com")

    get players_path

    expect(response.body).not_to include("regular@example.com")
  end

  it "shows the players page when a player hasn't played yet" do
    get players_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Newcomer")
  end
end
