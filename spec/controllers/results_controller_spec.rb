require "spec_helper"

describe ResultsController do
  describe "new" do
    it "exposes a new result" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      result = assigns(:result)
      result.should_not be_nil
      result.players.size.should == 2
    end

    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      assigns(:game).should == game
    end
  end

  describe "create" do
    it "creates a new result with the given players" do
      game = FactoryGirl.create(:game, :results => [])
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)

      post :create, :game_id => game, :result => {
        :player_1_id => player_1.id,
        :player_2_id => player_2.id,
        :winner_id => player_1.id
      }

      result = game.reload.results.first

      result.should_not be_nil
      result.players.map(&:id).sort.should == [player_1.id, player_2.id].sort
      result.winner.should == player_1
    end
  end
end
