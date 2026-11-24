require "rails_helper"

RSpec.describe RatingSystems::TrueSkill do
  it_behaves_like "a rating system"

  def standing(rank, *participants)
    RatingSystems::Standing.new(rank: rank, ratings: participants.to_h { |participant| [participant, described_class.initial_state] })
  end

  def scores(new_states)
    new_states.transform_values { |state| described_class.score(state) }
  end

  describe "rate" do
    it "orders players by finishing position, and teammates in a larger tied team score lower" do
      new_scores = scores(described_class.rate([
        standing(1, :p1),
        standing(2, :p2),
        standing(3, :p3, :p4),
        standing(3, :p5, :p6, :p7)
      ]))

      expect(new_scores[:p1]).to be > new_scores[:p2]
      expect(new_scores[:p2]).to be > new_scores[:p3]
      expect(new_scores[:p3]).to eq(new_scores[:p4])
      expect(new_scores[:p4]).to be > new_scores[:p5]
      expect(new_scores[:p5]).to eq(new_scores[:p6])
      expect(new_scores[:p6]).to eq(new_scores[:p7])
    end

    it "reduces uncertainty for everyone who played" do
      new_states = described_class.rate([standing(1, :a, :b), standing(2, :c)])

      new_states.each_value do |state|
        expect(state["deviation"]).to be < described_class::DEFAULT_DEVIATION
      end
    end
  end

  describe "score" do
    it "is the conservative estimate times 100" do
      expect(described_class.score({ "mean" => 30.0, "deviation" => 5.0 })).to eq(1500)
    end

    it "truncates toward zero" do
      expect(described_class.score({ "mean" => 0.0, "deviation" => 0.005 })).to eq(-1)
    end

    it "starts players at zero" do
      expect(described_class.score(described_class.initial_state)).to eq(0)
    end
  end
end
