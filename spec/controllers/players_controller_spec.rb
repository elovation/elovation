require "spec_helper"

describe PlayersController, :type => :controller do
  describe "new" do
    it "exposes a new player" do
      get :new

      assigns(:player).should_not be_nil
    end
  end

  describe "create" do
    it "creates a player given valid params" do
      post :create, :player => {:name => "Drew"}

      response.should redirect_to(dashboard_path)

      Player.where(:name => "Drew").first.should_not be_nil
    end
  end
end
