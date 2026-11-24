# Deterministic series of results used to pin rating behaviour.
#
# Each entry lists teams in finishing order as arrays of player names.
# A trailing :tie means every team in that result tied for first place.
module RatingScenarios
  ELO_SERIES = (0...45).map do |i|
    case i % 5
    when 0 then [["a"], ["b"]]
    when 1 then [["b"], ["c"]]
    when 2 then [["a"], ["c"], :tie]
    when 3 then [["c"], ["a"]]
    else [["a"], ["b"]]
    end
  end.freeze

  TRUESKILL_SERIES = [
    [["a", "b"], ["c", "d"]],
    [["c"], ["e"]],
    [["a"], ["b"], ["c"]],
    [["d", "e"], ["a", "b"], :tie],
    [["b", "c"], ["a", "e"]],
    [["e"], ["d"], ["c"], ["b"]],
    [["a", "c"], ["b", "d"]],
    [["d"], ["a"]],
    [["b", "e"], ["c", "d"], :tie],
    [["a", "b", "c"], ["d", "e"]],
    [["c"], ["a"]],
    [["e", "a"], ["b"], ["c", "d"]]
  ].freeze

  # Records every result in the series through ResultService (the live path).
  # Returns a hash of player name => Player.
  def play_series(game, series, names)
    players = names.to_h { |name| [name, FactoryBot.create(:player, name: "#{name}-#{SecureRandom.hex(4)}")] }

    series.each do |entry|
      response = ResultService.create(game, result_params(entry, players))
      raise "result was not recorded: #{response.result.errors.full_messages}" unless response.success?
    end

    players
  end

  def result_params(entry, players)
    tie = entry.last == :tie
    teams = entry.reject { |team| team == :tie }

    {
      teams: teams.each_with_index.to_h do |names, index|
        [index.to_s, { players: names.map { |name| players.fetch(name).id.to_s }, relation: tie ? "ties" : "defeats" }]
      end
    }
  end
end

RSpec.configure do |config|
  config.include RatingScenarios
end
