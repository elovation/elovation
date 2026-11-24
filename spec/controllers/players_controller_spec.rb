require "rails_helper"

describe PlayersController, :type => :controller do
  describe "new" do
    it "exposes a new player" do
      get :new

      expect(assigns(:player)).not_to be_nil
    end
  end

  describe "create" do
    it "creates a player and redirects to the players list" do
      post :create, params: {player: {name: "Drew", email: "drew@example.com"}}

      player = Player.where(name: "Drew", email: "drew@example.com").first

      expect(player).not_to be_nil
      expect(response).to redirect_to (players_path)
    end

    it "renders new given invalid params" do
      FactoryBot.create(:player, name: "Drew")

      post :create, params: {player: {name: "Drew"}}

      expect(response).to render_template (:new)
    end

    it "protects against mass assignment" do
      travel_to(Time.now) do
        post :create, params: {player: {created_at: 3.days.ago, name: "Drew"}}

        player = Player.where(name: "Drew").first
        expect(player.created_at).to be > 3.days.ago
      end
    end
  end

  describe "destroy" do
    it "deletes a player with no results" do
      player = FactoryBot.create(:player)

      delete :destroy, params: {id: player}

      expect(response).to redirect_to (players_path)
      expect(Player.find_by_id(player.id)).to be_nil
    end

    it "doesn't allow deleting a player with results" do
      result = FactoryBot.create(:result)
      player = result.players.first

      delete :destroy, params: {id: player}

      expect(response).to redirect_to (players_path)
      expect(Player.find_by_id(player.id)).to eq(player)
    end
  end

  describe "edit" do
    it "exposes the player for editing" do
      player = FactoryBot.create(:player)

      get :edit, params: {id: player}

      expect(assigns(:player)).to eq(player)
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the player show page" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        expect(response).to redirect_to (player_path(player))
      end

      it "updates the player with the provided attributes" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: "Second name"}}

        expect(player.reload.name).to eq("Second name")
      end

      it "protects against mass assignment" do
        travel_to(Time.now) do
          player = FactoryBot.create(:player, name: "First name")

          put :update, params: {id: player, player: {created_at: 3.days.ago}}

          expect(player.reload.created_at).to be > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        player = FactoryBot.create(:player, name: "First name")

        put :update, params: {id: player, player: {name: nil}}

        expect(response).to render_template (:edit)
      end
    end
  end

  describe "show" do
    it "exposes the player" do
      player = FactoryBot.create(:player)

      get :show, params: {id: player}

      expect(assigns(:player)).to eq(player)
    end
  end
end
