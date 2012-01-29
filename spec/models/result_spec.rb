require "spec_helper"

describe Result do
  describe "player_1_id" do
    it "returns the first player" do
      player1 = FactoryGirl.build(:player)
      player2 = FactoryGirl.build(:player)

      result = FactoryGirl.build(
        :result,
        :players => [player1, player2]
      )

      result.player_1_id.should == player1.id
    end
  end

  describe "player_2_id" do
    it "returns the second player" do
      player1 = FactoryGirl.build(:player)
      player2 = FactoryGirl.build(:player)

      result = FactoryGirl.build(
        :result,
        :players => [player1, player2]
      )

      result.player_2_id.should == player2.id
    end
  end
end
