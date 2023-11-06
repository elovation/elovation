require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "active?" do
    it "is true if the player as played a game in the past 4 weeks" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)
      rating = FactoryBot.create(:rating, player: player, game: game)
      teams = [
        FactoryBot.create(:team, rank: 1, players: [player]),
        FactoryBot.create(:team, rank: 2)
      ]
      result =
        FactoryBot.create(
          :result,
          teams: teams,
          game: game,
          created_at: 5.weeks.ago
        )
      rating.active?.should == false
      teams = [
        FactoryBot.create(:team, rank: 1, players: [player]),
        FactoryBot.create(:team, rank: 2)
      ]
      result =
        FactoryBot.create(
          :result,
          teams: teams,
          game: game,
          created_at: 4.weeks.ago + 1.hour
        )
      rating.active?.should == true
    end
  end

  describe "as_json" do
    it "returns the json representation of the result" do
      player = FactoryBot.build(:player, name: "John")
      rating = FactoryBot.build(:rating, value: 1000, player: player)

      rating.as_json.should ==
        { player: { name: player.name, email: player.email }, value: 1000 }
    end
  end

  describe "most_recent_result" do
    it "returns the most recent result for the game and player" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)
      rating = FactoryBot.create(:rating, player: player, game: game)
      result_5_weeks_ago =
        FactoryBot.create(
          :result,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2)
          ],
          game: game,
          created_at: 5.weeks.ago
        )
      rating.most_recent_result.should == result_5_weeks_ago
      result_4_weeks_ago =
        FactoryBot.create(
          :result,
          teams: [
            FactoryBot.create(:team, rank: 2, players: [player]),
            FactoryBot.create(:team, rank: 1)
          ],
          game: game,
          created_at: 4.weeks.ago
        )
      rating.most_recent_result.should == result_4_weeks_ago
      result_6_weeks_ago =
        FactoryBot.create(
          :result,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2)
          ],
          game: game,
          created_at: 6.weeks.ago
        )
      rating.most_recent_result.should == result_4_weeks_ago
    end
  end

  describe "destroy" do
    it "removes history events" do
      rating = FactoryBot.create(:rating)
      history_event = FactoryBot.create(:rating_history_event, rating: rating)

      rating.destroy

      RatingHistoryEvent.find_by_id(history_event.id).should(be_nil)
    end
    # TODO: .destroy_all should update player rankings and attributes appropriately refer to line 272 rater_spec.rb
  end

  describe "rewind!" do
    it "resets the rating to the previous rating" do
      rating =
        FactoryBot.create(
          :rating,
          value: 1002,
          trueskill_mean: 52,
          trueskill_deviation: 22
        )
      FactoryBot.create(
        :rating_history_event,
        rating: rating,
        value: 1001,
        trueskill_mean: 51,
        trueskill_deviation: 21
      )
      FactoryBot.create(
        :rating_history_event,
        rating: rating,
        value: 1002,
        trueskill_mean: 52,
        trueskill_deviation: 22
      )

      rating.rewind!

      rating.reload

      rating.value.should == 1001
      rating.trueskill_mean.should == 51
      rating.trueskill_deviation.should == 21
    end

    it "deletes the most recent history event" do
      rating = FactoryBot.create(:rating, value: 1002)
      FactoryBot.create(:rating_history_event, rating: rating, value: 1001)
      history_event =
        FactoryBot.create(:rating_history_event, rating: rating, value: 1002)

      rating.rewind!

      RatingHistoryEvent.find_by_id(history_event.id).should(be_nil)
    end

    it "destroys the rating if there is only one history event" do
      rating = FactoryBot.create(:rating, value: 1002)
      history_event =
        FactoryBot.create(:rating_history_event, rating: rating, value: 1002)

      rating.rewind!

      Rating.find_by_id(rating.id).should(be_nil)
      RatingHistoryEvent.find_by_id(history_event.id).should(be_nil)
    end
  end
end
