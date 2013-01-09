require "spec_helper"

describe Result do
  describe "as_json" do
    it "returns the json representation of the result" do
      created_at = Time.now

      winner = FactoryGirl.build(:team, rank: 1)
      loser = FactoryGirl.build(:team, rank: 2)
      result = FactoryGirl.build(:result, teams: [winner, loser], created_at: created_at)

      result.as_json.should == {
        :winner => winner.players.first.name,
        :loser => loser.players.first.name,
        :created_at => created_at.utc.to_s
      }
    end
  end

  describe "for_game" do
    it "finds results for the given game" do
      player = FactoryGirl.create(:player)
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)
      result_for_game1 = FactoryGirl.create(:result, :game => game1, :teams => [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])
      result_for_game2 = FactoryGirl.create(:result, :game => game2, :teams => [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)])
      player.results.for_game(game1).should == [result_for_game1]
      player.results.for_game(game2).should == [result_for_game2]
    end
  end

  describe "most_recent?" do
    it "returns true if the result is the most recent for both players" do
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      result = FactoryGirl.create(:result, :game => game, :teams => [FactoryGirl.create(:team, rank: 1, players: [player_1]), FactoryGirl.create(:team, rank: 2, players: [player_2])])

      result.should be_most_recent
    end

    it "returns false if the result is not the most recent for both players" do
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)

      old_result = FactoryGirl.create(:result, :game => game, :teams => [FactoryGirl.create(:team, rank: 1, players: [player_1]), FactoryGirl.create(:team, rank: 2, players: [player_2])])
      FactoryGirl.create(:result, :game => game, :teams => [FactoryGirl.create(:team, rank: 1, players: [player_1]), FactoryGirl.create(:team, rank: 2, players: [player_3])])

      old_result.should_not be_most_recent
    end
  end

  describe "players" do
    it "has the winners and losers" do
      result = FactoryGirl.create(:result)
      result.players.should include(result.winners.first)
      result.players.should include(result.losers.first)
    end
  end

  describe "validations" do
    context "base validations" do
      it "requires a winner" do
        player1 = FactoryGirl.build(:player)
        player2 = FactoryGirl.build(:player)
        result = Result.new
        result.teams.build rank: 2, players: [player1]
        result.teams.build rank: 3, players: [player2]

        result.should_not be_valid
        result.errors[:teams].should include("must have a winner")
      end

      it "requires two teams" do
        player = FactoryGirl.build(:player)
        result = Result.new
        result.teams.build rank: 1, players: [player]

        result.should_not be_valid
        result.errors[:teams].should == ["must have two teams"]
      end

      it "doesn't allow the same player twice" do
        player = FactoryGirl.build(:player, :name => nil)

        result = Result.new
        result.teams.build rank: 1, players: [player]
        result.teams.build rank: 2, players: [player]

        result.should_not be_valid
        result.errors[:teams].should == ["must have unique players"]
      end

      it "does not complain about similarity when both winner and loser are nil" do
        result = Result.new

        result.should_not be_valid
        result.errors[:base].should_not == ["Winner and loser can't be the same player"]
      end
    end
  end
end
