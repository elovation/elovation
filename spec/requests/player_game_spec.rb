require "rails_helper"

RSpec.describe "A player's page for a game", type: :request do
  # Regression: the heading read the player's rating without checking they
  # had one, so a game they hadn't played returned 500.
  it "shows a game the player hasn't played yet" do
    player = FactoryBot.create(:player, name: "Newcomer")
    game = FactoryBot.create(:elo_game, name: "Chess")

    get player_game_path(player, game)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Newcomer — Chess")
  end
end
