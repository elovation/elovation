require "spec_helper"

describe Player do
  describe "name" do
    it "has a name" do
      player = FactoryGirl.create(:player, :name => "Drew")

      player.name.should == "Drew"
    end
  end

  describe "validations" do
    context "name" do
      it "must be unique" do
        FactoryGirl.create(:player, :name => "Drew")
        player = FactoryGirl.build(:player, :name => "Drew")

        player.should_not be_valid
        player.errors[:name].should == ["has already been taken"]
      end
    end
  end
end
