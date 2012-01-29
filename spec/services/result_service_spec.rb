require "spec_helper"

describe ResultService do
  describe "build_result" do
    it "builds a result given a game and params" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      result = ResultService.build_result(
        game,
        :winner_id => player1.id.to_s,
        :loser_id => player2.id.to_s
      )

      result.player_ids.sort.should == [player1.id, player2.id].sort
      result.winner.should == player1
      result.loser.should == player2
      result.game.should == game
    end
  end
end
