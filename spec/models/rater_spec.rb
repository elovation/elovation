require "rails_helper"

RSpec.describe Rater, type: :model do
  describe Rater::EloRater do
    describe "update_ratings" do
      it "creates new ratings" do
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 2, players: [player2])

        game.rater.update_ratings(game, [team1, team2])

        player1.ratings.where(game_id: game.id).should_not be_empty
        player2.ratings.where(game_id: game.id).should_not be_empty
      end

      it "works with ties" do
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 1, players: [player2])

        game.rater.update_ratings(game, [team1, team2])

        rating1 = player1.ratings.where(game_id: game.id).first
        rating2 = player2.ratings.where(game_id: game.id).first
        rating1.reload.value.should == game.rater.default_attributes[:value]
        rating2.reload.value.should == game.rater.default_attributes[:value]
      end

      it "updates existing ratings" do
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 2, players: [player2])
        rating1 = FactoryBot.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value]
        )
        rating2 = FactoryBot.create(
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
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 2, players: [player2])
        rating1 = FactoryBot.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          pro: false
        )

        Rater::EloRater.any_instance.stubs(:to_elo).returns(Elo::Player.new(pro: true))

        game.rater.update_ratings(game, [team1, team2])

        rating1.reload.pro?.should be true
      end

      it "creates rating history events" do
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 2, players: [player2])
        rating1 = FactoryBot.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value]
        )
        rating2 = FactoryBot.create(
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
        game = FactoryBot.create(:elo_game)
        player1 = FactoryBot.create(:player)
        player2 = FactoryBot.create(:player)
        team1 = FactoryBot.create(:team, rank: 1, players: [player1])
        team2 = FactoryBot.create(:team, rank: 2, players: [player2])

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
        rating = FactoryBot.build(:rating, value: 1000)
        rater.to_elo(rating).rating.should == 1000
      end

      it "includes number of games played" do
        player = FactoryBot.create(:player)
        game = FactoryBot.create(:game)
        2.times { FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)]) }

        rating = FactoryBot.create(:rating, player: player, game: game)

        rater.to_elo(rating).games_played.should == 2
      end

      it "includes the pro flag" do
        rating = FactoryBot.build(:rating, pro: true)
        rater.to_elo(rating).should be_pro
      end
    end
  end

  describe Rater::TrueSkillRater do
    describe "update_ratings" do
      let(:game) { FactoryBot.create(:game, max_number_of_teams: nil, max_number_of_players_per_team: nil) }
      let(:player1) { FactoryBot.create(:player) }
      let(:player2) { FactoryBot.create(:player) }
      let(:player3) { FactoryBot.create(:player) }
      let(:player4) { FactoryBot.create(:player) }
      let(:player5) { FactoryBot.create(:player) }
      let(:player6) { FactoryBot.create(:player) }
      let(:player7) { FactoryBot.create(:player) }
      let(:team1) { FactoryBot.create(:team, rank: 1, players: [player1]) }
      let(:team2) { FactoryBot.create(:team, rank: 2, players: [player2]) }
      let(:team3) { FactoryBot.create(:team, rank: 3, players: [player3, player4]) }
      let(:team4) { FactoryBot.create(:team, rank: 3, players: [player5, player6, player7]) }

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
        rating1 = FactoryBot.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )
        rating2 = FactoryBot.create(
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
        rating1 = FactoryBot.create(
          :rating,
          game: game,
          player: player1,
          value: game.rater.default_attributes[:value],
          trueskill_mean: game.rater.default_attributes[:trueskill_mean],
          trueskill_deviation: game.rater.default_attributes[:trueskill_deviation]
        )
        rating2 = FactoryBot.create(
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
        team1b = team1.clone
        team2b = team2.clone
        team3b = team3.clone
        team4b = team4.clone
        gameb  = game.clone

        game.rater.update_ratings(game, [team1, team2, team3, team4])
        old_ratings = game.ratings.map(&:value)

        # TODO: .destroy_all should update player rankings and attributes appropriately
        # in a previous version of this codebase, you where able to call game.ratings.destroy_all
        # then compare the old_ratings to the same game/teams, but updating ruby/rails versions
        # broke this, it is unclear whether this was working by chance or whether
        # it is now broken. As the call "game.ratings.destroy_all" is only required in this instance and isn't a feature
        # of the app, I decided to rely on clones, and prove that the ratings update appropriately.... in future it may
        # be wise to write tests surrounding the .destroy_all functionality and make sure it updates the players ratings/deviations
        # appropriately. 
        # game.ratings.destroy_all
        # game.reload

        gameb.rater.update_ratings(gameb, [team4b, team2b, team3b, team1b])
        gameb.ratings.map(&:value).should == old_ratings
      end
    end

    describe "to_trueskill" do
      it "returns an trueskill rating with the correct mean" do
        game = FactoryBot.create(:game)
        rating = FactoryBot.build :rating, trueskill_mean: Rater::TrueSkillRater::DefaultMean
        game.rater.to_trueskill(rating).mean.should == Rater::TrueSkillRater::DefaultMean
      end

      it "returns an trueskill rating with the correct mean" do
        game = FactoryBot.create(:game)
        rating = FactoryBot.build :rating, trueskill_deviation: Rater::TrueSkillRater::DefaultDeviation
        game.rater.to_trueskill(rating).deviation.should == Rater::TrueSkillRater::DefaultDeviation
      end
    end
  end
end