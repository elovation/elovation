require "spec_helper"

describe GamesController, :type => :controller do
  describe "new" do
    it "exposes a new game" do
      get :new

      assigns(:game).should_not be_nil
    end
  end
end
