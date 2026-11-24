require "rails_helper"

RSpec.describe RatingSystems::Replay do
  def placings(*teams)
    teams.each_with_index.map { |participants, index| RatingSystems::Placing.new(rank: index + 1, participants: participants) }
  end

  it "starts participants from the rating system's initial state" do
    replay = described_class.new(RatingSystems::Elo)

    expect(replay.state_of(:newcomer)).to eq(RatingSystems::Elo.initial_state)
  end

  it "carries each participant's state from one result to the next" do
    replay = described_class.new(RatingSystems::Elo)
    replay.play(placings([:a], [:b]))
    after_first = replay.state_of(:a)

    replay.play(placings([:a], [:c]))

    expected = RatingSystems::Elo.rate([
      RatingSystems::Standing.new(rank: 1, ratings: { a: after_first }),
      RatingSystems::Standing.new(rank: 2, ratings: { c: RatingSystems::Elo.initial_state })
    ])
    expect(replay.state_of(:a)).to eq(expected[:a])
    expect(replay.state_of(:c)).to eq(expected[:c])
  end

  it "returns the new states of the result's participants" do
    replay = described_class.new(RatingSystems::TrueSkill)

    expect(replay.play(placings([:a, :b], [:c])).keys).to contain_exactly(:a, :b, :c)
  end

  it "continues from prior states" do
    prior = { "rating" => 1500, "games_played" => 50, "pro" => false }
    replay = described_class.new(RatingSystems::Elo, { a: prior })

    replay.play(placings([:b], [:a]))

    expect(replay.state_of(:a)["games_played"]).to eq(51)
  end

  it "runs any rating system over the same results" do
    series = [placings([:a], [:b]), placings([:b], [:c]), placings([:a], [:c])]

    scores = RatingSystems.all.to_h do |system|
      replay = described_class.new(system)
      series.each { |result| replay.play(result) }
      [system.key, replay.scores]
    end

    scores.each_value do |by_participant|
      expect(by_participant[:a]).to be > by_participant[:c]
    end
  end
end
