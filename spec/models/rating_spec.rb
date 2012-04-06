require "spec_helper"

describe Rating do
  describe "active?" do
    it "is true if the player as played a game in the past 4 weeks" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, :player => player, :game => game)
      result = FactoryGirl.create(:result, :winner => player, :game => game, :created_at => 5.weeks.ago)
      rating.active?.should == false
      result = FactoryGirl.create(:result, :winner => player, :game => game, :created_at => 4.weeks.ago + 1.hour)
      rating.active?.should == true
    end
  end

  describe "as_json" do
    it "returns the json representation of the result" do
      player = FactoryGirl.build(:player, :name => "John")
      rating = FactoryGirl.build(:rating, :value => 1000, :player => player)

      rating.as_json.should == {
        :player => player.name,
        :value => 1000
      }
    end
  end

  describe "most_recent_result" do
    it "returns the most recent result for the game and player" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, :player => player, :game => game)
      result_5_weeks_ago = FactoryGirl.create(:result, :winner => player, :game => game, :created_at => 5.weeks.ago)
      rating.most_recent_result.should == result_5_weeks_ago
      result_4_weeks_ago = FactoryGirl.create(:result, :winner => player, :game => game, :created_at => 4.weeks.ago)
      rating.most_recent_result.should == result_4_weeks_ago
      result_6_weeks_ago = FactoryGirl.create(:result, :winner => player, :game => game, :created_at => 6.weeks.ago)
      rating.most_recent_result.should == result_4_weeks_ago
    end
  end

  describe "to_elo" do
    it "returns an elo player with the correct value" do
      rating = FactoryGirl.build(:rating, :value => 1000)
      rating.to_elo.rating.should == 1000
    end

    it "includes number of games played" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      2.times { FactoryGirl.create(:result, :game => game, :winner => player) }

      rating = FactoryGirl.create(:rating, :player => player, :game => game)

      rating.to_elo.games_played.should == 2
    end

    it "includes the pro flag" do
      rating = FactoryGirl.build(:rating, :pro => true)
      rating.to_elo.should be_pro
    end
  end

  describe "destroy" do
    it "removes history events" do
      rating = FactoryGirl.create(:rating)
      history_event = FactoryGirl.create(:rating_history_event, :rating => rating)

      rating.destroy

      RatingHistoryEvent.find_by_id(history_event.id).should be_nil
    end
  end

  describe "rewind!" do
    it "resets the rating to the previous rating" do
      rating = FactoryGirl.create(:rating, :value => 1002)
      FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1001)
      FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1002)

      rating.rewind!

      rating.reload.value.should == 1001
    end

    it "deletes the most recent history event" do
      rating = FactoryGirl.create(:rating, :value => 1002)
      FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1001)
      history_event = FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1002)

      rating.rewind!

      RatingHistoryEvent.find_by_id(history_event.id).should be_nil
    end

    it "destroys the rating if there is only one history event" do
      rating = FactoryGirl.create(:rating, :value => 1002)
      history_event = FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1002)

      rating.rewind!

      Rating.find_by_id(rating.id).should be_nil
      RatingHistoryEvent.find_by_id(history_event.id).should be_nil
    end
  end
end
