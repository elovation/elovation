require "spec_helper"

describe RatingHistoryEvent do
  describe "events scope" do
    it "should return the RatingHistoryEvents associated with a player and event" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, game: game, player: player, value: 1002)
      rating_history_events = [
          FactoryGirl.create(:rating_history_event, rating: rating, value: 1001),
          FactoryGirl.create(:rating_history_event, rating: rating, value: 1000)
      ]

      RatingHistoryEvent.events(player, game).should == rating_history_events
    end
  end
end
