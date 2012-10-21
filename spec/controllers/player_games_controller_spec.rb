require "spec_helper"

describe PlayerGamesController do
  describe "show" do
    it "renders successfully with the player and the game" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      get :show, :player_id => player, :id => game
      response.should be_success

      assigns(:game).should == game
      assigns(:player).should == player
    end

    it "exposes deletable results" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)
      FactoryGirl.create(:result, :game => game)

      get :show, :player_id => player, :id => game

      assigns(:deletable_results).should == Result.find_deletable_for(game)
    end
  end
end
