require "spec_helper"

describe RatingsController do
  describe "index" do
    it "renders ratins for the given game" do
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, game: game)

      get :index, game_id: game

      assigns(:game).should == game
      response.should render_template(:index)
    end
  end
end
