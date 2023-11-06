require "rails_helper"

describe DashboardController, type: :controller do
  describe "show" do
    it "displays all players and games" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)

      get(:show)

      assigns(:players).should == [player]
      assigns(:games).should == [game]
    end
  end
end
