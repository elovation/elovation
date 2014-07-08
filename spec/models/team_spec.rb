require "spec_helper"

describe Team do

  describe "validations" do
    context "base validations" do
      it "requires a rank" do
        team = Team.new(rank: nil)

        team.should_not be_valid
        team.errors[:rank].should == ["can't be blank"]
      end
    end
  end
end
