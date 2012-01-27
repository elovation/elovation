require "spec_helper"

describe GamesController, :type => :controller do
  describe "new" do
    it "exposes a new game" do
      get :new

      assigns(:game).should_not be_nil
    end
  end

  describe "create" do
    it "creates a player given valid params" do
      post :create, :game => {:name => "Go", :description => "Best game ever."}

      response.should redirect_to(dashboard_path)

      Game.where(:name => "Go", :description => "Best game ever.").first.should_not be_nil
    end
  end
end
