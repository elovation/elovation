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
end
