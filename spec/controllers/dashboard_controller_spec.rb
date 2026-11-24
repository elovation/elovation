require "rails_helper"

describe DashboardController, :type => :controller do
  describe "show" do
    it "displays all players and games" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)

      get :index

      expect(assigns(:players)).to eq([player])
      expect(assigns(:games)).to eq([game])
    end
  end
end
