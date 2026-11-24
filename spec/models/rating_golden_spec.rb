require "rails_helper"

# Characterization tests: these values were recorded from the original
# implementation (the elo gem and saulabs/trueskill driven by Rater) before the
# rating systems were restructured. Recording results must keep producing them.
RSpec.describe "Recorded ratings", type: :model do
  def rating_for(game, player)
    Rating.find_by!(game: game, player: player)
  end

  def history_for(game, player)
    rating_for(game, player).history_events.reorder(:created_at, :id).map(&:value)
  end

  describe "an Elo game" do
    let(:game) { FactoryBot.create(:elo_game, max_number_of_teams: 2) }
    let!(:players) { play_series(game, RatingScenarios::ELO_SERIES, %w[a b c]) }

    it "matches the recorded final ratings" do
      expect(rating_for(game, players["a"]).value).to eq(1032)
      expect(rating_for(game, players["b"]).value).to eq(926)
      expect(rating_for(game, players["c"]).value).to eq(998)
    end

    it "matches the recorded rating history" do
      expect(history_for(game, players["a"])).to eq([1012, 1011, 997, 1009, 1020, 1018, 1004, 1015, 1026, 1024, 1010, 1021, 1031, 1029, 1014, 1024, 1034, 1032, 1017, 1027, 1036, 1034, 1019, 1029, 1038, 1036, 1021, 1030, 1039, 1037, 1028, 1033, 1038, 1036, 1027, 1032])
      expect(history_for(game, players["b"])).to eq([987, 999, 986, 974, 987, 975, 963, 976, 964, 953, 967, 956, 945, 959, 948, 938, 952, 941, 931, 945, 935, 925, 940, 930, 921, 936, 926])
      expect(history_for(game, players["c"])).to eq([987, 987, 1000, 986, 987, 1000, 986, 987, 1000, 985, 986, 1000, 985, 986, 1000, 985, 986, 1000, 985, 986, 1000, 984, 985, 999, 983, 984, 998])
    end
  end

  describe "a TrueSkill game" do
    let(:game) { FactoryBot.create(:trueskill_game, max_number_of_teams: nil, max_number_of_players_per_team: nil) }
    let!(:players) { play_series(game, RatingScenarios::TRUESKILL_SERIES, %w[a b c d e]) }

    RECORDED = {
      "a" => { value: 1313, mean: 24.673077065857743, deviation: 3.845798220758832, history: [473, 1552, 1382, 1214, 1474, 1336, 1396, 1290, 1313] },
      "b" => { value: 1706, mean: 27.38752004376593, deviation: 3.4406974318078647, history: [473, 1072, 916, 1246, 977, 920, 1042, 1083, 1706] },
      "c" => { value: 1223, mean: 21.834867806171015, deviation: 3.1986028986698254, history: [-140, 649, 511, 879, 1155, 1293, 1316, 1355, 1613, 1223] },
      "d" => { value: 1219, mean: 22.539059951468523, deviation: 3.448869010297287, history: [-140, 658, 1347, 1284, 1662, 1686, 1676, 1219] },
      "e" => { value: 1629, mean: 28.51302802363977, deviation: 4.073401136180936, history: [-140, 480, 292, 1444, 1612, 1602, 1629] }
    }.freeze

    it "matches the recorded final ratings, means and deviations" do
      RECORDED.each do |name, recorded|
        rating = rating_for(game, players[name])
        expect(rating.value).to eq(recorded[:value]), "value for #{name}"
        expect(rating.trueskill_mean).to be_within(1e-9).of(recorded[:mean]), "mean for #{name}"
        expect(rating.trueskill_deviation).to be_within(1e-9).of(recorded[:deviation]), "deviation for #{name}"
      end
    end

    it "matches the recorded rating history" do
      RECORDED.each do |name, recorded|
        expect(history_for(game, players[name])).to eq(recorded[:history]), "history for #{name}"
      end
    end
  end
end
