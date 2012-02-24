require "spec_helper"

describe PlayersController do
  describe "new" do
    it "exposes a new player" do
      get :new

      assigns(:player).should_not be_nil
    end
  end

  describe "create" do
    it "creates a player and redirects to the player show page" do
      post :create, :player => {:name => "Drew"}

      player = Player.where(:name => "Drew").first

      player.should_not be_nil
      response.should redirect_to(player_path(player))
    end

    it "renders new given invalid params" do
      FactoryGirl.create(:player, :name => "Drew")

      post :create, :player => {:name => "Drew"}

      response.should render_template(:new)
    end
  end

  describe "edit" do
    it "exposes the player for editing" do
      player = FactoryGirl.create(:player)

      get :edit, :id => player

      assigns(:player).should == player
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the player show page" do
        player = FactoryGirl.create(:player, :name => "First name")

        put :update, :id => player, :player => {:name => "Second name"}

        response.should redirect_to(player_path(player))
      end

      it "updates the player with the provided attributes" do
        player = FactoryGirl.create(:player, :name => "First name")

        put :update, :id => player, :player => {:name => "Second name"}

        player.reload.name.should == "Second name"
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        player = FactoryGirl.create(:player, :name => "First name")

        put :update, :id => player, :player => {:name => nil}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the player" do
      player = FactoryGirl.create(:player)

      get :show, :id => player

      assigns(:player).should == player
    end
  end
end
