require "spec_helper"

describe Result do
  describe "validations" do
    context "base validations" do
      it "doesn't allow winner and loser to be the same player" do
        player = FactoryGirl.build(:player, :name => nil)

        result = Result.new(
          :winner => player,
          :loser => player
        )

        result.should_not be_valid
        result.errors[:base].should == ["Winner and loser can't be the same player"]
      end
    end
  end
end
