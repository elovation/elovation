require "rails_helper"

RSpec.describe RatingSystems::Format do
  def game(teams:, players:)
    Game.new(min_number_of_teams: teams.begin, max_number_of_teams: teams.end,
             min_number_of_players_per_team: players.begin, max_number_of_players_per_team: players.end)
  end

  let(:one_on_one) { described_class.new(teams: 2..2, players_per_team: 1..1, summary: "1v1 games") }
  let(:open) { described_class.new(teams: 2.., players_per_team: 1.., summary: "any teams") }

  describe "supports?" do
    it "accepts a game whose limits fall within the format" do
      expect(one_on_one.supports?(game(teams: 2..2, players: 1..1))).to be(true)
      expect(open.supports?(game(teams: 2..6, players: 1..4))).to be(true)
    end

    it "rejects a game that allows more than the format" do
      expect(one_on_one.supports?(game(teams: 2..3, players: 1..1))).to be(false)
      expect(one_on_one.supports?(game(teams: 2..2, players: 1..2))).to be(false)
    end

    it "treats a missing maximum as unlimited" do
      expect(one_on_one.supports?(game(teams: 2.., players: 1..1))).to be(false)
      expect(open.supports?(game(teams: 2.., players: 1..))).to be(true)
    end
  end

  describe "fixed limits" do
    it "is the only value a closed range allows" do
      expect([one_on_one.fixed_teams, one_on_one.fixed_players_per_team]).to eq([2, 1])
    end

    it "is nil when more than one value is allowed" do
      expect([open.fixed_teams, open.fixed_players_per_team]).to eq([nil, nil])
    end
  end
end
