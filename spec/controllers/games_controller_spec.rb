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

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          post :create, :game => {:created_at => 3.days.ago, :name => "Go"}

          game = Game.where(:name => "Go").first
          game.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, :game => {:name => nil}

        response.should render_template(:new)
      end
    end
  end

  describe "destroy" do
    it "allows deleting games without results" do
      game = FactoryGirl.create(:game, :name => "First name")

      delete :destroy, :id => game

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should be_nil
    end

    it "doesn't allow deleting games with results" do
      game = FactoryGirl.create(:game, :name => "First name")
      FactoryGirl.create(:result, :game => game)

      delete :destroy, :id => game

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should == game
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

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          game = FactoryGirl.create(:game, :name => "First name")

          put :update, :id => game, :game => {:created_at => 3.days.ago}

          game.created_at.should > 3.days.ago
        end
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

        challenge1 = FactoryGirl.create(:challenge, :game => game, :challenger => player1, :challengee => player2)
        challenge2 = FactoryGirl.create(:challenge, :game => game, :challenger => player2, :challengee => player3)

        get :show, :id => game, :format => :json

        json_data = JSON.parse(response.body)
        json_data.should == {
          "name" => game.name,
          "ratings" => [
            {"player" => {"name" => player1.name, "email" => player1.email}, "value" => 1003},
            {"player" => {"name" => player2.name, "email" => player2.email}, "value" => 1002},
            {"player" => {"name" => player3.name, "email" => player3.email}, "value" => 1001}
          ],
          "results" => [
            {"winner" => player1.name, "loser" => player2.name, "created_at" => Time.now.utc.to_s},
            {"winner" => player2.name, "loser" => player3.name, "created_at" => Time.now.utc.to_s},
            {"winner" => player3.name, "loser" => player1.name, "created_at" => Time.now.utc.to_s}
          ],
          "challenges" => [
            {"challenger" => player1.name, "challengee" => player2.name, "expires_at" => 5.days.from_now.utc.to_s },
            {"challenger" => player2.name, "challengee" => player3.name, "expires_at" => 5.days.from_now.utc.to_s }
          ]
        }
      end
    end
  end
end
