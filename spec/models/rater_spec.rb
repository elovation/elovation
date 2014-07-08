require "spec_helper"

describe Rater do
  describe Rater::EloRater do
    describe "update_ratings" do
      it "creates new ratings" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])

        game.rater.update_ratings(game, [team1, team2])

        player1.ratings.where(game_id: game.id).should_not be_empty
        player2.ratings.where(game_id: game.id).should_not be_empty
      end

      it "works with ties" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 1, players: [player2])

        game.rater.update_ratings(game, [team1, team2])

        rating1 = player1.ratings.where(game_id: game.id).first
        rating2 = player2.ratings.where(game_id: game.id).first
        rating1.reload.value.should == game.rater.default_attributes[:value]
        rating2.reload.value.should == game.rater.default_attributes[:value]
      end

      it "updates existing ratings" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])
        rating1 = FactoryGirl.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value]
        )
        rating2 = FactoryGirl.create(
          :rating,
          game: game,
          player: player2,
          value: game.rater.default_attributes[:value]
        )

        game.rater.update_ratings(game, [team1, team2])

        rating1.reload.value.should > game.rater.default_attributes[:value]
        rating2.reload.value.should < game.rater.default_attributes[:value]
      end

      it "persists the value of the pro flag" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])
        rating1 = FactoryGirl.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          pro: false
        )

        Rater::EloRater.any_instance.stubs(:to_elo).returns(Elo::Player.new(pro: true))

        game.rater.update_ratings(game, [team1, team2])

        rating1.reload.pro?.should be_true
      end

      it "creates rating history events" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])
        rating1 = FactoryGirl.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value]
        )
        rating2 = FactoryGirl.create(
          :rating,
          game: game,
          player: player2,
          value: game.rater.default_attributes[:value]
        )

        game.rater.update_ratings(game, [team1, team2])

        new_rating1 = rating1.reload.value
        new_rating2 = rating2.reload.value

        rating1.history_events.first.value.should == new_rating1
        rating2.history_events.first.value.should == new_rating2
      end

      it "returns the same result regardless of team order" do
        game = FactoryGirl.create(:elo_game)
        player1 = FactoryGirl.create(:player)
        player2 = FactoryGirl.create(:player)
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])

        game.rater.update_ratings(game, [team2, team1])

        old_ratings = game.ratings.map(&:value)

        game.ratings.destroy_all
        game.reload

        game.rater.update_ratings(game, [team1, team2])
        game.ratings.map(&:value).should == old_ratings
      end
    end

    describe "to_elo" do
      let(:rater) { Rater::EloRater.new }
      it "returns an elo player with the correct value" do
        rating = FactoryGirl.build(:rating, value: 1000)
        rater.to_elo(rating).rating.should == 1000
      end

      it "includes number of games played" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)
        2.times { FactoryGirl.create(:result, game: game, teams: [FactoryGirl.create(:team, rank: 1, players: [player]), FactoryGirl.create(:team, rank: 2)]) }

        rating = FactoryGirl.create(:rating, player: player, game: game)

        rater.to_elo(rating).games_played.should == 2
      end

      it "includes the pro flag" do
        rating = FactoryGirl.build(:rating, pro: true)
        rater.to_elo(rating).should be_pro
      end
    end
  end

  describe Rater::TrueSkillRater do
    describe "update_ratings" do
      let(:game) { FactoryGirl.create(:game, max_number_of_teams: nil, max_number_of_players_per_team: nil) }
      let(:player1) { FactoryGirl.create(:player) }
      let(:player2) { FactoryGirl.create(:player) }
      let(:player3) { FactoryGirl.create(:player) }
      let(:player4) { FactoryGirl.create(:player) }
      let(:player5) { FactoryGirl.create(:player) }
      let(:player6) { FactoryGirl.create(:player) }
      let(:player7) { FactoryGirl.create(:player) }
      let(:team1) { FactoryGirl.create(:team, rank: 1, players: [player1]) }
      let(:team2) { FactoryGirl.create(:team, rank: 2, players: [player2]) }
      let(:team3) { FactoryGirl.create(:team, rank: 3, players: [player3, player4]) }
      let(:team4) { FactoryGirl.create(:team, rank: 3, players: [player5, player6, player7]) }

      it "creates new ratings" do
        game.rater.update_ratings(game, [team1, team2, team3, team4])

        player1.ratings.where(game_id: game.id).should_not be_empty
        player2.ratings.where(game_id: game.id).should_not be_empty
        player3.ratings.where(game_id: game.id).should_not be_empty
        player4.ratings.where(game_id: game.id).should_not be_empty
        player5.ratings.where(game_id: game.id).should_not be_empty
        player6.ratings.where(game_id: game.id).should_not be_empty
        player7.ratings.where(game_id: game.id).should_not be_empty
      end

      it "updates existing ratings" do
        rating1 = FactoryGirl.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )
        rating2 = FactoryGirl.create(
          :rating,
          game: game,
          player: player2,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )

        game.rater.update_ratings(game, [team1, team2, team3, team4])

        rating1.reload
        rating2.reload

        rating1.value.should > rating2.value
      end

      it "creates rating history events" do
        rating1 = FactoryGirl.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )
        rating2 = FactoryGirl.create(
          :rating,
          game: game,
          player: player2,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )

        game.rater.update_ratings(game, [team1, team2, team3, team4])

        new_rating1 = rating1.reload.value
        new_rating2 = rating2.reload.value

        rating1.history_events.first.value.should == new_rating1
        rating2.history_events.first.value.should == new_rating2
        RatingHistoryEvent.count.should == 7
      end

      it "calculates rank as value" do
        game.rater.update_ratings(game, [team1, team2, team3, team4])

        rating1 = player1.ratings.find_or_create(game)
        rating2 = player2.ratings.find_or_create(game)

        rating1.value.should == (((rating1.trueskill_mean - (3 * rating1.trueskill_deviation)) * 100)).floor
        rating1.value.should > rating2.value
      end

      it "is sane" do
        game.rater.update_ratings(game, [team1, team2, team3, team4])

        rating1 = player1.ratings.find_or_create(game)
        rating2 = player2.ratings.find_or_create(game)
        rating3 = player3.ratings.find_or_create(game)
        rating4 = player4.ratings.find_or_create(game)
        rating5 = player5.ratings.find_or_create(game)
        rating6 = player6.ratings.find_or_create(game)
        rating7 = player7.ratings.find_or_create(game)

        rating1.value.should > rating2.value
        rating2.value.should > rating3.value
        rating3.value.should == rating4.value
        rating4.value.should > rating5.value
        rating5.value.should == rating6.value
        rating6.value.should == rating7.value
      end

      it "returns the same result regardless of team order" do
        game.rater.update_ratings(game, [team1, team2, team3, team4])
        old_ratings = game.ratings.map(&:value)

        game.ratings.destroy_all
        game.reload

        game.rater.update_ratings(game, [team4, team2, team3, team1])
        game.ratings.map(&:value).should == old_ratings
      end
    end

    describe "to_trueskill" do
      it "returns an trueskill rating with the correct mean" do
        game = FactoryGirl.create(:game)
        rating = FactoryGirl.build :rating, trueskill_mean: Rater::TrueSkillRater::DefaultMean
        game.rater.to_trueskill(rating).mean.should == Rater::TrueSkillRater::DefaultMean
      end

      it "returns an trueskill rating with the correct mean" do
        game = FactoryGirl.create(:game)
        rating = FactoryGirl.build :rating, trueskill_deviation: Rater::TrueSkillRater::DefaultDeviation
        game.rater.to_trueskill(rating).deviation.should == Rater::TrueSkillRater::DefaultDeviation
      end
    end
  end
end

