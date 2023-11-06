require "rails_helper"

describe PlayerGamesController, type: :controller do
  describe "show" do
    it "renders successfully with the player and the game" do
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)

      get(:show, params: { player_id: player, id: game })
      response.should(be_success)

      assigns(:game).should == game
      assigns(:player).should == player
    end
  end
end
