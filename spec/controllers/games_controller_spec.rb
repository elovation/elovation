require "rails_helper"

describe GamesController, :type => :controller do
  describe "new" do
    it "exposes a new game" do
      get :new

      assigns(:game).should_not be_nil
    end
  end

  describe "edit" do
    it "exposes the game for editing" do
      game = FactoryBot.create(:game)

      get :edit, params: {id: game}

      assigns(:game).should == game
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a game" do
        game_attributes = FactoryBot.attributes_for(:game)
        post :create, params: {game: game_attributes}

        Game.where(name: game_attributes[:name]).first.should_not be_nil
      end

      it "redirects to the game's show page" do
        game_attributes = FactoryBot.attributes_for(:game)
        post :create, params: {game: game_attributes}

        game = Game.where(name: game_attributes[:name]).first

        response.should redirect_to(game_path(game))
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          game_attributes = FactoryBot.attributes_for(:game, created_at: 3.days.ago)
          post :create, params: {game: game_attributes}

          game = Game.where(name: game_attributes[:name]).first
          game.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, params: {game: {name: nil}}

        response.should render_template(:new)
      end
    end
  end

  describe "destroy" do
    it "allows deleting games without results" do
      game = FactoryBot.create(:game, name: "First name")

      delete :destroy, params: {id: game}

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should be_nil
    end

    it "doesn't allow deleting games with results" do
      game = FactoryBot.create(:game, name: "First name")
      FactoryBot.create(:result, game: game)

      delete :destroy, params: {id: game}

      response.should redirect_to(dashboard_path)
      Game.find_by_id(game.id).should == game
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the game's show page" do
        game = FactoryBot.create(:game, name: "First name")

        put :update, params: {id: game, game: {name: "Second name"}}

        response.should redirect_to(game_path(game))
      end

      it "updates the game with the provided attributes" do
        game = FactoryBot.create(:game, name: "First name")

        put :update, params: {id: game, game: {name: "Second name"}}

        game.reload.name.should == "Second name"
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          game = FactoryBot.create(:game, name: "First name")

          put :update, params: {id: game, game: {created_at: 3.days.ago}}

          game.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        game = FactoryBot.create(:game, name: "First name")

        put :update, params: {id: game, game: {name: nil}}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the game" do
      game = FactoryBot.create(:game)

      get :show, params: {id: game}

      assigns(:game).should == game
    end

    it "returns a json response" do
      Timecop.freeze(Time.now) do
        game = FactoryBot.create(:game)

        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        player3 = FactoryBot.create(:player)

        rating1 = FactoryBot.create(:rating, game: game, value: 1003, player: player1)
        rating2 = FactoryBot.create(:rating, game: game, value: 1002, player: player2)
        rating3 = FactoryBot.create(:rating, game: game, value: 1001, player: player3)

        result1 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player1]), FactoryBot.create(:team, rank: 2, players: [player2])])
        result2 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player2]), FactoryBot.create(:team, rank: 2, players: [player3])])
        result3 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player3]), FactoryBot.create(:team, rank: 2, players: [player1])])

        get :show, params: {id: game, format: :json}

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
