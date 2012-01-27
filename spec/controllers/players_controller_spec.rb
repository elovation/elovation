require "spec_helper"

describe PlayersController, :type => :controller do
  describe "new" do
    it "exposes a new player" do
      get :new

      assigns(:player).should_not be_nil
    end
  end
end
