require "spec_helper"

describe Player do
  describe "name" do
    it "has a name" do
      player = FactoryGirl.create(:player, :name => "Drew")

      player.name.should == "Drew"
    end
  end
end
