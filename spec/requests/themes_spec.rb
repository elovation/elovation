require "rails_helper"

RSpec.describe "Themes", type: :request do
  def body_theme = response.body[/<body data-theme="([^"]+)"/, 1]

  around do |example|
    original = ENV["ELOVATION_THEME"]
    example.run
  ensure
    ENV["ELOVATION_THEME"] = original
  end

  it "gives a game's pages the game's theme, for everyone" do
    game = FactoryBot.create(:elo_game, theme: "chess")

    get game_path(game)
    expect(body_theme).to eq("chess")

    get new_game_result_path(game)
    expect(body_theme).to eq("chess")
  end

  it "uses the site's theme for a game without one, and for every other page" do
    ENV["ELOVATION_THEME"] = "foosball"
    game = FactoryBot.create(:elo_game, theme: nil)

    get game_path(game)
    expect(body_theme).to eq("foosball")

    get players_path
    expect(body_theme).to eq("foosball")
  end

  it "falls back to the generic theme when the site's isn't set or isn't a theme" do
    ENV["ELOVATION_THEME"] = "neon"

    get players_path

    expect(body_theme).to eq("generic")
  end

  it "lets a game's theme be changed from its form" do
    game = FactoryBot.create(:elo_game)

    patch game_path(game), params: { game: { theme: "table-tennis" } }

    expect(game.reload.theme).to eq("table-tennis")
  end

  it "rejects a theme that doesn't exist" do
    game = FactoryBot.build(:elo_game, theme: "neon")

    expect(game).not_to be_valid
    expect(game.errors[:theme]).to be_present
  end
end
