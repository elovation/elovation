require "spec_helper"

describe PlayersController do
  describe "new" do
    it "exposes a new player" do
      get :new

      assigns(:player).should_not be_nil
    end
  end

  describe "create" do
    it "creates a player and redirects to the dashboard given valid params" do
      post :create, :player => {:name => "Drew"}

      response.should redirect_to(dashboard_path)

      Player.where(:name => "Drew").first.should_not be_nil
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
      it "redirects to the dashboard page" do
        player = FactoryGirl.create(:player, :name => "First name")

        put :update, :id => player, :player => {:name => "Second name"}

        response.should redirect_to(dashboard_path)
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

  describe "destroy" do
    it "redirects to the dashboard path" do
      player = FactoryGirl.create(:player)

      delete :destroy, :id => player

      response.should redirect_to(dashboard_path)
    end

    it "deletes the given player" do
      player = FactoryGirl.create(:player)

      delete :destroy, :id => player

      Player.find_by_id(player.id).should be_nil
    end
  end
end
