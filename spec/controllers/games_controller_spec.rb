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

      get :edit, id: game

      assigns(:game).should == game
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a game" do
        game_attributes = FactoryGirl.attributes_for(:game)
        post :create, game: game_attributes

        Game.where(name: game_attributes[:name]).first.should_not be_nil
      end

      it "redirects to the game's show page" do
        game_attributes = FactoryGirl.attributes_for(:game)
        post :create, game: game_attributes

        game = Game.where(name: game_attributes[:name]).first

        response.should redirect_to(game_path(game))
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          game_attributes = FactoryGirl.attributes_for(:game, created_at: 3.days.ago)
          post :create, game: game_attributes

          game = Game.where(name: game_attributes[:name]).first
          game.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, game: {name: nil}

        response.should render_template(:new)
      end
    end
  end

  describe "destroy" do
    it "allows deleting games without results" do
      game = FactoryGirl.create(:game, name: "First name")

      delete :destroy, id: game

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should be_nil
    end

    it "doesn't allow deleting games with results" do
      game = FactoryGirl.create(:game, name: "First name")
      FactoryGirl.create(:result, game: game)

      delete :destroy, id: game

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should == game
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the game's show page" do
        game = FactoryGirl.create(:game, name: "First name")

        put :update, id: game, game: {name: "Second name"}

        response.should redirect_to(game_path(game))
      end

      it "updates the game with the provided attributes" do
        game = FactoryGirl.create(:game, name: "First name")

        put :update, id: game, game: {name: "Second name"}

        game.reload.name.should == "Second name"
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          game = FactoryGirl.create(:game, name: "First name")

          put :update, id: game, game: {created_at: 3.days.ago}

          game.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        game = FactoryGirl.create(:game, name: "First name")

        put :update, id: game, game: {name: nil}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :show, id: game

      assigns(:game).should == game
    end

    it "returns a json response" do
      Timecop.freeze(Time.now) do
        game = FactoryGirl.create(:game)

        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        player3 = FactoryGirl.create(:player)

        rating1 = FactoryGirl.create(:rating, game: game, value: 1003, player: player1)
        rating2 = FactoryGirl.create(:rating, game: game, value: 1002, player: player2)
        rating3 = FactoryGirl.create(:rating, game: game, value: 1001, player: player3)

        result1 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player1]), FactoryGirl.create(:team, rank: 2, players: [player2])])
        result2 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player2]), FactoryGirl.create(:team, rank: 2, players: [player3])])
        result3 = FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player3]), FactoryGirl.create(:team, rank: 2, players: [player1])])

        get :show, id: game, format: :json

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
          ]
        }
      end
    end
  end
end
