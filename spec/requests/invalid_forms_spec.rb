require "rails_helper"

# Regression: an invalid form re-rendered with 200, which Turbo ignores, so
# submitting it appeared to do nothing, and the forms had nowhere to show
# what was wrong.
RSpec.describe "Submitting an invalid form", type: :request do
  describe "a result" do
    let(:game) { FactoryBot.create(:trueskill_game, max_number_of_players_per_team: 2) }
    let(:ada) { FactoryBot.create(:player, name: "Ada") }
    let(:bob) { FactoryBot.create(:player, name: "Bob") }

    before do
      post game_results_path(game), params: { result: { teams: {
        "0" => { players: [ada.id.to_s, bob.id.to_s], relation: "defeats" },
        "1" => { players: [ada.id.to_s] }
      } } }
    end

    it "responds 422 so Turbo shows the form again" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "says what's wrong" do
      expect(response.body).to include("Teams must have unique players")
    end

    it "keeps the players that were chosen" do
      winners = response.body[%r{<select[^>]*name="result\[teams\]\[0\]\[players\]\[\]".*?</select>}m]
      losers = response.body[%r{<select[^>]*name="result\[teams\]\[1\]\[players\]\[\]".*?</select>}m]

      expect(winners.scan(/<option selected="selected" value="(\d+)"/).flatten).to contain_exactly(ada.id.to_s, bob.id.to_s)
      expect(losers.scan(/<option selected="selected" value="(\d+)"/).flatten).to eq([ada.id.to_s])
    end
  end

  describe "editing a game" do
    let(:game) { FactoryBot.create(:trueskill_game) }

    before { patch game_path(game), params: { game: { name: "" } } }

    it "says what's wrong" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("can&#39;t be blank")
    end
  end

  describe "a game" do
    before { post games_path, params: { game: { name: "", rating_type: "elo", min_number_of_teams: 2, min_number_of_players_per_team: 1 } } }

    it "responds 422 so Turbo shows the form again" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "says what's wrong" do
      expect(response.body).to include("can&#39;t be blank")
    end
  end
end
