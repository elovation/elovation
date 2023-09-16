require "rails_helper"

describe PlayersController, :type => :controller do
  describe "new" do
    it "exposes a new player" do
      get :new

      assigns(:player).should_not be_nil
    end
  end

  describe "create" do
    it "creates a player and redirects to dashboard" do
      post :create, params: {player: {name: "Drew", email: "drew@example.com"}}

      player = Player.where(name: "Drew", email: "drew@example.com").first

      player.should_not be_nil
      response.should redirect_to(dashboard_path)
    end

    it "renders new given invalid params" do
      FactoryBot.create(:player, name: "Drew")

      post :create, params: {player: {name: "Drew"}}

      response.should render_template(:new)
    end

    it "protects against mass assignment" do
      Timecop.freeze(Time.now) do
        post :create, params: {player: {created_at: 3.days.ago, name: "Drew"}}

        player = Player.where(name: "Drew").first
        player.created_at.should > 3.days.ago
      end
    end
  end

  describe "destroy" do
    it "deletes a player with no results" do
      player = FactoryBot.create(:player)

      delete :destroy, params: {id: player}

      response.should redirect_to(dashboard_path)
      Player.find_by_id(player.id).should be_nil
    end

    it "doesn't allow deleting a player with results" do
      result = FactoryBot.create(:result)
      player = result.players.first

      delete :destroy, params: {id: player}

      response.should redirect_to(dashboard_path)
      Player.find_by_id(player.id).should == player
    end
  end

  describe "edit" do
    it "exposes the player for editing" do
      player = FactoryBot.create(:player)

      get :edit, params: {id: player}

      assigns(:player).should == player
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the player show page" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        response.should redirect_to(player_path(player))
      end

      it "updates the player with the provided attributes" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        player.reload.name.should == "Second name"
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          player = FactoryBot.create(:player, name: "First name")

          put :update, params: {id: player, player: {created_at: 3.days.ago}}

          player.reload.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: nil}}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the player" do
      player = FactoryBot.create(:player)

      get :show, params: {id: player}

      assigns(:player).should == player
    end
  end
end
