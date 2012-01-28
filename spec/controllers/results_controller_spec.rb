require "spec_helper"

describe ResultsController do
  describe "new" do
    it "exposes a new result" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      assigns(:result).should_not be_nil
    end
  end
end
