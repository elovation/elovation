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

  describe "validations" do
    context "name" do
      it "must be present" do
        game = FactoryGirl.build(:game, :name => nil)

        game.should_not be_valid
        game.errors[:name].should == ["can't be blank"]
      end
    end

    context "description" do
      it "must be present" do
        game = FactoryGirl.build(:game, :description => nil)

        game.should_not be_valid
        game.errors[:description].should == ["can't be blank"]
      end
    end
  end
end
