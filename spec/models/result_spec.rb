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

  describe "for_game" do
    it "finds results for the given game" do
      player = FactoryGirl.create(:player)
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)
      result_for_game1 = FactoryGirl.create(:result, :game => game1, :winner => player)
      result_for_game2 = FactoryGirl.create(:result, :game => game2, :winner => player)
      player.results.for_game(game1).should == [result_for_game1]
      player.results.for_game(game2).should == [result_for_game2]
    end
  end

  describe "find_deletable" do
    it "finds results that are most recent for both players" do
      game_1 = FactoryGirl.create(:game)
      game_2 = FactoryGirl.create(:game)

      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)
      player_4 = FactoryGirl.create(:player)

      r1 = FactoryGirl.create(:result, :game => game_1, :winner => player_1, :loser => player_2)
      r2 = FactoryGirl.create(:result, :game => game_1, :winner => player_3, :loser => player_4)

      FactoryGirl.create(:result, :game => game_2, :winner => player_1, :loser => player_2)
      r3 = FactoryGirl.create(:result, :game => game_2, :winner => player_2, :loser => player_3)

      Result.find_deletable_for(game_1).should == [ r1, r2 ]
      Result.find_deletable_for(game_2).should == [ r3 ]
    end
  end

  describe "most_recent?" do
    it "returns true if the result is the most recent for both players" do
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      result = FactoryGirl.create(:result, :game => game, :winner => player_1, :loser => player_2, :players => [player_1, player_2])

      result.should be_most_recent
    end

    it "returns false if the result is not the most recent for both players" do
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      old_result = FactoryGirl.create(:result, :game => game, :winner => player_1, :loser => player_2, :players => [player_1, player_2])
      FactoryGirl.create(:result, :game => game, :winner => player_1, :loser => player_3, :players => [player_1, player_3])

      old_result.should_not be_most_recent
    end
  end

  describe "validations" do
    context "base validations" do
      it "requires a winner" do
        player = FactoryGirl.build(:player)
        result = Result.new(:loser => player)

        result.should_not be_valid
        result.errors[:winner].should == ["can't be blank"]
      end

      it "requires a loser" do
        player = FactoryGirl.build(:player)
        result = Result.new(:winner => player)

        result.should_not be_valid
        result.errors[:loser].should == ["can't be blank"]
      end

      it "doesn't allow winner and loser to be the same player" do
        player = FactoryGirl.build(:player, :name => nil)

        result = Result.new(
          :winner => player,
          :loser => player
        )

        result.should_not be_valid
        result.errors[:base].should == ["Winner and loser can't be the same player"]
      end

      it "does not complain about similarity when both winner and loser are nil" do
        result = Result.new()

        result.should_not be_valid
        result.errors[:base].should_not == ["Winner and loser can't be the same player"]
      end
    end
  end
end
