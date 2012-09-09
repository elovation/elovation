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
    context "with active challenge" do
      it "resolves challenge" do
        game = FactoryGirl.create(:game)
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        FactoryGirl.create(:challenge, :game => game, :challenger => player_1, :challengee => player_2)

        post :create, :game_id => game, :result => {
          :winner_id => player_2.id,
          :loser_id => player_1.id
        }

        game.reload

        result = game.results.first
        challenge = game.challenges.first

        challenge.result.should == result
      end

      it "resolves all matching challenges" do
        game = FactoryGirl.create(:game)
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        FactoryGirl.create(:challenge, :game => game, :challenger => player_1, :challengee => player_2)
        FactoryGirl.create(:challenge, :game => game, :challenger => player_2, :challengee => player_1)

        post :create, :game_id => game, :result => {
          :winner_id => player_2.id,
          :loser_id => player_1.id
        }

        Challenge.active.count.should == 0
      end
    end
  end

  describe "destroy" do
    context "the most recent result for each player" do
      it "destroys the result and resets the elo for each player" do
        game = FactoryGirl.create(:game, :results => [])
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        ResultService.create(game, :winner_id => player_1.id, :loser_id => player_2.id).result

        player_1_rating = player_1.ratings.where(:game_id => game.id).first
        player_2_rating = player_2.ratings.where(:game_id => game.id).first

        old_rating_1 = player_1_rating.value
        old_rating_2 = player_2_rating.value

        result = ResultService.create(game, :winner_id => player_1.id, :loser_id => player_2.id).result

        player_1_rating.reload.value.should_not == old_rating_1
        player_2_rating.reload.value.should_not == old_rating_2

        request.env['HTTP_REFERER'] = game_path(game)

        delete :destroy, :game_id => game, :id => result

        response.should redirect_to(game_path(game))

        player_1_rating.reload.value.should == old_rating_1
        player_2_rating.reload.value.should == old_rating_2

        player_1.reload.results.size.should == 1
        player_2.reload.results.size.should == 1
      end
    end
  end
end
