require "spec_helper"

describe PlayerGamesController do
  describe "show" do
    it "renders successfully with the player and the game" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      get :show, player_id: player, id: game
      response.should be_success

      assigns(:game).should == game
      assigns(:player).should == player
    end
  end
end
