require "rails_helper"

RSpec.describe "A game's page", type: :request do
  context "before any results" do
    let(:game) { FactoryBot.create(:elo_game) }

    before { get game_path(game) }

    # Regression: it showed an empty ratings table and a blank chart.
    it "says there are no ratings yet instead of an empty table and chart" do
      expect(response.body).to include("No ratings yet")
      expect(response.body).not_to include("id='ratings'")
      expect(response.body).not_to include("Progress")
    end

    # Regression: Edit only appeared once a game had results.
    it "can be edited or deleted" do
      expect(response.body).to match(%r{<a [^>]*href="#{edit_game_path(game)}"[^>]*>Edit</a>})
      expect(response.body).to include(">Delete</button>")
    end
  end

  context "when no one has played for four weeks" do
    it "says so, and links to every rating" do
      game = FactoryBot.create(:elo_game)
      travel_to(5.weeks.ago) do
        ResultService.create(game, teams: { "0" => { players: [FactoryBot.create(:player).id.to_s] }, "1" => { players: [FactoryBot.create(:player).id.to_s] } })
      end

      get game_path(game)

      expect(response.body).to include("No one has played in the last four weeks")
      expect(response.body).to include(">View All</a>")
    end
  end
end
