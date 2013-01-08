require "spec_helper"

describe ResultService do
  describe "create" do
    it "builds a result given a game and params" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        :teams => [{players: [player1.id.to_s]}, {players: [player2.id.to_s]}]
      )

      response.should be_success
      result = response.result
      result.winner.should == player1
      result.loser.should == player2
      result.game.should == game
    end

    it "returns success as false if there are validation errors" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        :teams => [{players: [player.id.to_s]}, {players: [player.id.to_s]}]
      )

      response.should_not be_success
    end

    it "handles nil winner or loser" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      response = ResultService.create(
        game,
        :teams => [{players: [player.id.to_s]}, {players: []}]
      )

      response.should_not be_success

      response = ResultService.create(
        game,
        :teams => [{players: [nil]}, {players: [player.id.to_s]}]
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
          :teams => [{players: [player1.id.to_s]}, {players: [player2.id.to_s]}]
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

  describe "destroy" do
    it "returns a successful response if the result is destroyed" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      result = ResultService.create(
        game,
        :teams => [{players: [player1.id.to_s]}, {players: [player2.id.to_s]}]
      ).result

      response = ResultService.destroy(result)

      response.should be_success
      Result.find_by_id(result.id).should be_nil
    end

    it "returns an unsuccessful response and does not destroy the result if it is not the most recent for both players" do
      game = FactoryGirl.create(:game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)

      old_result = FactoryGirl.create(:result, :game => game, :winner => player_1, :loser => player_2)
      FactoryGirl.create(:result, :game => game, :winner => player_1, :loser => player_3)

      response = ResultService.destroy(old_result)

      response.should_not be_success
      Result.find_by_id(old_result.id).should_not be_nil
    end
  end
end
