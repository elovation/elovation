require 'rails_helper'

RSpec.describe Team, type: :model do
  describe "validations" do
    context "base validations" do
      it "requires a rank" do
        team = Team.new(rank: nil)

        expect(team).not_to be_valid
        expect(team.errors[:rank]).to eq(["can't be blank"])
      end
    end
  end
end
