require "spec_helper"

describe GamesController do
  describe "new" do
    it "exposes a new game" do
      get :new

      assigns(:game).should_not be_nil
    end
  end

  describe "edit" do
    it "exposes the game for editing" do
      game = FactoryGirl.create(:game)

      get :edit, :id => game

      assigns(:game).should == game
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a game" do
        post :create, :game => {:name => "Go"}

        Game.where(:name => "Go").first.should_not be_nil
      end

      it "redirects to the game's show page" do
        post :create, :game => {:name => "Go"}

        game = Game.where(:name => "Go").first

        response.should redirect_to(game_path(game))
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, :game => {:name => nil}

        response.should render_template(:new)
      end
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the game's show page" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => "Second name"}

        response.should redirect_to(game_path(game))
      end

      it "updates the game with the provided attributes" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => "Second name"}

        game.reload.name.should == "Second name"
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => nil}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :show, :id => game

      assigns(:game).should == game
    end

    it "returns a json response" do
      Timecop.freeze(Time.now) do
        game = FactoryGirl.create(:game)

        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        player3 = FactoryGirl.create(:player)

        rating1 = FactoryGirl.create(:rating, :game => game, :value => 1003, :player => player1)
        rating2 = FactoryGirl.create(:rating, :game => game, :value => 1002, :player => player2)
        rating3 = FactoryGirl.create(:rating, :game => game, :value => 1001, :player => player3)

        result1 = FactoryGirl.create(:result, :game => game, :winner => player1, :loser => player2)
        result2 = FactoryGirl.create(:result, :game => game, :winner => player2, :loser => player3)
        result3 = FactoryGirl.create(:result, :game => game, :winner => player3, :loser => player1)

        get :show, :id => game, :format => :json

        response.body.should == {
          "name" => game.name,
          "ratings" => [
            {"player" => player1.name, "value" => 1003},
            {"player" => player2.name, "value" => 1002},
            {"player" => player3.name, "value" => 1001}
          ],
          "results" => [
            {"winner" => player1.name, "loser" => player2.name, "created_at" => Time.now.utc.to_s},
            {"winner" => player2.name, "loser" => player3.name, "created_at" => Time.now.utc.to_s},
            {"winner" => player3.name, "loser" => player1.name, "created_at" => Time.now.utc.to_s}
          ]
        }.to_json
      end
    end
  end
end
