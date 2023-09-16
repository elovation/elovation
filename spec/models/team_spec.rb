require 'rails_helper'

RSpec.describe Team, type: :model do
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
