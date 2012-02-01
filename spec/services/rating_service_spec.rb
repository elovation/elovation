require "spec_helper"

describe RatingService do
  describe "update" do
    it "creates new ratings" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)

      RatingService.update(game, player1, player2)

      player1.ratings.where(:game_id => game.id).should_not be_empty
      player2.ratings.where(:game_id => game.id).should_not be_empty
    end

    it "updates existing ratings" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      rating1 = FactoryGirl.create(
        :rating,
        :game => game,
        :player => player1,
        :value => Rating::DefaultValue
      )
      rating2 = FactoryGirl.create(
        :rating,
        :game => game,
        :player => player2,
        :value => Rating::DefaultValue
      )

      RatingService.update(game, player1, player2)

      rating1.reload.value.should > Rating::DefaultValue
      rating2.reload.value.should < Rating::DefaultValue
    end
  end
end
