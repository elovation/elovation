require "spec_helper"

describe ResultsController do
  describe "new" do
    it "exposes a new result" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      assigns(:result).should_not be_nil
    end

    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      assigns(:game).should == game
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a new result with the given players" do
        game = FactoryGirl.create(:game, :results => [])
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        post :create, :game_id => game, :result => {
          :winner_id => player_1.id,
          :loser_id => player_2.id
        }

        result = game.reload.results.first

        result.should_not be_nil
        result.players.map(&:id).sort.should == [player_1.id, player_2.id].sort
        result.winner.should == player_1
        result.loser.should == player_2
      end
    end

    context "with invalid params" do
      it "renders the new page" do
        game = FactoryGirl.create(:game, :results => [])
        player = FactoryGirl.create(:player)

        post :create, :game_id => game, :result => {
          :winner_id => player.id,
          :loser_id => player.id
        }

        response.should render_template(:new)
      end
    end
  end
end
