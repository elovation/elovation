require "rails_helper"

describe RatingsController, :type => :controller do
  describe "index" do
    it "renders ratins for the given game" do
      game = FactoryBot.create(:game)
      rating = FactoryBot.create(:rating, game: game)

      get :index, params: {game_id: game}

      expect(assigns(:game)).to eq(game)
      expect(response).to render_template (:index)
    end
  end
end
