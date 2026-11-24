require "rails_helper"

RSpec.describe Leaderboard do
  def record(game, *teams, at: Time.current)
    result = FactoryBot.create(:result, game: game, created_at: at,
                                        teams: teams.each_with_index.map { |players, index| FactoryBot.create(:team, rank: index + 1, players: players) })
    game.leaderboard.record(result)
    result
  end

  def snapshot(game)
    game.ratings.order(:player_id).map { |rating| [rating.player_id, rating.value, rating.state] }
  end

  let(:game) { FactoryBot.create(:elo_game, max_number_of_teams: 2) }
  let(:alice) { FactoryBot.create(:player) }
  let(:bob) { FactoryBot.create(:player) }
  let(:carol) { FactoryBot.create(:player) }

  describe "record" do
    it "creates ratings from the rating system's initial state" do
      record(game, [alice], [bob])

      expect(alice.ratings.find_by(game: game).value).to eq(1012)
      expect(bob.ratings.find_by(game: game).value).to eq(987)
    end

    it "continues from the players' current ratings" do
      record(game, [alice], [bob])
      record(game, [alice], [bob])

      expect(alice.ratings.find_by(game: game).state["games_played"]).to eq(2)
    end

    it "stamps rating history with the time of the result" do
      played_at = 3.days.ago.change(usec: 0)
      record(game, [alice], [bob], at: played_at)

      expect(alice.ratings.find_by(game: game).history_events.first.created_at).to eq(played_at)
    end
  end

  describe "retract" do
    it "restores the previous ratings and removes the result" do
      record(game, [alice], [bob])
      before = snapshot(game)
      latest = record(game, [bob], [alice])

      expect(game.leaderboard.retract(latest)).to be(true)

      expect(snapshot(game)).to eq(before)
      expect(Result.exists?(latest.id)).to be(false)
    end

    it "removes ratings that only came from the retracted result" do
      record(game, [alice], [bob])
      latest = record(game, [alice], [carol])

      game.leaderboard.retract(latest)

      expect(carol.ratings.find_by(game: game)).to be_nil
    end

    it "refuses to retract a result that isn't the latest for all its players" do
      earlier = record(game, [alice], [bob])
      record(game, [alice], [carol])

      expect(game.leaderboard.retract(earlier)).to be(false)
      expect(Result.exists?(earlier.id)).to be(true)
    end
  end

  describe "rebuild" do
    # Regression: rebuilding used to count each player's games from all saved
    # results, so Elo K-factors differed from the live calculation.
    it "reproduces live Elo ratings for players past the 30 game threshold" do
      play_series(game, RatingScenarios::ELO_SERIES, %w[a b c])
      live = snapshot(game)

      game.leaderboard.rebuild

      expect(snapshot(game)).to eq(live)
    end

    it "reproduces live TrueSkill ratings" do
      game = FactoryBot.create(:trueskill_game, max_number_of_teams: nil, max_number_of_players_per_team: nil)
      play_series(game, RatingScenarios::TRUESKILL_SERIES, %w[a b c d e])
      live = snapshot(game)

      game.leaderboard.rebuild

      expect(snapshot(game)).to eq(live)
    end

    it "keeps history dated by when each result was played" do
      first_played = 5.days.ago.change(usec: 0)
      record(game, [alice], [bob], at: first_played)
      record(game, [alice], [bob], at: 2.days.ago)

      game.leaderboard.rebuild

      expect(alice.ratings.find_by(game: game).history_events.last.created_at).to eq(first_played)
    end
  end

  describe "preview" do
    it "rates the game's results under another rating system without saving" do
      record(game, [alice], [bob])
      record(game, [alice], [carol])
      before = snapshot(game)

      entries = game.leaderboard.preview(RatingSystems::TrueSkill)

      expect(entries.map(&:player_id).first).to eq(alice.id)
      expect(entries.map(&:score)).to eq(entries.map(&:score).sort.reverse)
      expect(entries.first.state.keys).to match_array(RatingSystems::TrueSkill.initial_state.keys)
      expect(snapshot(game)).to eq(before)
    end

    it "refuses a rating system that can't rate the game's format" do
      team_game = FactoryBot.create(:trueskill_game, max_number_of_players_per_team: 2)

      expect { team_game.leaderboard.preview(RatingSystems::Elo) }
        .to raise_error(ArgumentError, "Elo can only be used with 1v1 games")
    end

    it "matches the recorded ratings under the game's own rating system" do
      play_series(game, RatingScenarios::ELO_SERIES, %w[a b c])

      preview = game.leaderboard.preview.map { |entry| [entry.player_id, entry.score, entry.state] }

      expect(preview.sort).to eq(snapshot(game).sort)
    end
  end
end
