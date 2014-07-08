require "spec_helper"

describe ResultsHelper do
  describe "player_options" do
    it "returns an associative array of player names and ids" do
      player1 = FactoryGirl.create(:player, name: "First")
      player2 = FactoryGirl.create(:player, name: "Second")

      helper.player_options.should == [["First", player1.id], ["Second", player2.id]]
    end
  end
end
