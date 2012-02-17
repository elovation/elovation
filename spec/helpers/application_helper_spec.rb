require "spec_helper"

describe ApplicationHelper do
  describe "gravatar" do
    it "uses a default image if the player doesn't have a gravatar" do
      player = FactoryGirl.build(:player, :gravatar => "")

      helper.gravatar_url(player).should == "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&s=32"
    end

    it "uses the player's gravatar url if he/she has one" do
      player = FactoryGirl.build(:player, :gravatar => "http://www.gravatar.com/avatar/deadbeef")

      helper.gravatar_url(player).should == "http://www.gravatar.com/avatar/deadbeef?s=32"
    end

    it "can take a custom size" do
      player = FactoryGirl.build(:player, :gravatar => "http://www.gravatar.com/avatar/deadbeef")

      helper.gravatar_url(player, :size => 64).should == "http://www.gravatar.com/avatar/deadbeef?s=64"
    end
  end
end
