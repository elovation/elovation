require "spec_helper"

describe Game do
  describe "name" do
    it "has a name" do
      game = FactoryGirl.create(:game, :name => "Go")

      game.name.should == "Go"
    end
  end

  describe "description" do
    it "has a description" do
      game = FactoryGirl.create(:game, :description => "An ancient game.")

      game.description.should == "An ancient game."
    end
  end
end
