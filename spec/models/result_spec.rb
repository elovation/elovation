require "spec_helper"

describe Result do
  describe "as_json" do
    it "returns the json representation of the result" do
      created_at = Time.now

      winner = FactoryGirl.build(:player, :name => "Jane")
      loser = FactoryGirl.build(:player, :name => "John")
      result = FactoryGirl.build(:result, :winner => winner, :loser => loser, :created_at => created_at)

      result.as_json.should == {
        :winner => winner.name,
        :loser => loser.name,
        :created_at => created_at.utc.to_s
      }
    end
  end

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
