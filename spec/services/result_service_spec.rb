require "spec_helper"

describe ResultService do
  describe "create" do
    it "builds a result given a game and params" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        :winner_id => player1.id.to_s,
        :loser_id => player2.id.to_s
      )

      response.should be_success
      result = response.result
      result.player_ids.sort.should == [player1.id, player2.id].sort
      result.winner.should == player1
      result.loser.should == player2
      result.game.should == game
    end

    it "returns success as false if there are validation errors" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        :winner_id => player.id.to_s,
        :loser_id => player.id.to_s
      )

      response.should_not be_success
    end

    context "ratings" do
      it "builds ratings for both players and increments the winner" do
        game = FactoryGirl.create(:game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)

        ResultService.create(
          game,
          :winner_id => player1.id.to_s,
          :loser_id => player2.id.to_s
        )

        rating1 = player1.ratings.where(:game_id => game.id).first
        rating2 = player2.ratings.where(:game_id => game.id).first

        rating1.should_not be_nil
        rating1.value.should > Rating::DefaultValue

        rating2.should_not be_nil
        rating2.value.should < Rating::DefaultValue
      end
    end
  end
end
