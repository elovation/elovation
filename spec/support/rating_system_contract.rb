# The contract every rating system must satisfy (see app/models/rating_systems.rb).
#
#   RSpec.describe RatingSystems::MySystem do
#     it_behaves_like "a rating system"
#   end
#
# Uses the simplest format every rating system supports: two teams of one.
RSpec.shared_examples "a rating system" do
  subject(:system) { described_class }

  def standing(rank, ratings)
    RatingSystems::Standing.new(rank: rank, ratings: ratings)
  end

  def deep_freeze(state)
    state.transform_values(&:freeze).freeze
  end

  let(:winner_beats_loser) do
    [standing(1, { "winner" => system.initial_state }), standing(2, { "loser" => system.initial_state })]
  end

  it "is registered under its key" do
    expect(RatingSystems.fetch(system.key)).to be(system)
  end

  it "has a description" do
    expect(system.description).to be_a(String).and be_present
  end

  it "has an initial state that survives a JSON round trip" do
    expect(JSON.parse(JSON.generate(system.initial_state))).to eq(system.initial_state)
  end

  it "scores states as integers" do
    expect(system.score(system.initial_state)).to be_an(Integer)
  end

  it "returns a new state for every participant, shaped like the initial state" do
    new_states = system.rate(winner_beats_loser)

    expect(new_states.keys).to contain_exactly("winner", "loser")
    new_states.each_value do |state|
      expect(state.keys).to match_array(system.initial_state.keys)
      expect(JSON.parse(JSON.generate(state))).to eq(state)
    end
  end

  it "scores the winner above the loser" do
    new_states = system.rate(winner_beats_loser)

    expect(system.score(new_states["winner"])).to be > system.score(new_states["loser"])
  end

  it "scores tied participants equally" do
    new_states = system.rate([standing(1, { "x" => system.initial_state }), standing(1, { "y" => system.initial_state })])

    expect(system.score(new_states["x"])).to eq(system.score(new_states["y"]))
  end

  it "does not depend on the order of the standings" do
    expect(system.rate(winner_beats_loser.reverse)).to eq(system.rate(winner_beats_loser))
  end

  it "does not mutate the states it is given" do
    frozen = [standing(1, { "winner" => deep_freeze(system.initial_state) }), standing(2, { "loser" => deep_freeze(system.initial_state) })]

    expect { system.rate(frozen) }.not_to raise_error
  end
end
