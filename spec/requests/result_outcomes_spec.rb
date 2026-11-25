require "rails_helper"

RSpec.describe "How results read", type: :request do
  def text_of(html) = Nokogiri::HTML(html).css("#results li").map { |li| li.text.squish }

  def record(game, *teams, tie: false)
    params = teams.each_with_index.to_h do |team, index|
      [index.to_s, { players: team.map { |player| player.id.to_s }, relation: tie ? "ties" : "defeats" }]
    end
    ResultService.create(game, teams: params).result
  end

  let(:ada) { FactoryBot.create(:player, name: "Ada") }
  let(:bob) { FactoryBot.create(:player, name: "Bob") }
  let(:cy) { FactoryBot.create(:player, name: "Cy") }
  let(:di) { FactoryBot.create(:player, name: "Di") }

  # Regression: every team after the winner was listed together, so second
  # and third place looked the same ("Ada defeats Bob Cy").
  it "gives placings when more than two teams played" do
    game = FactoryBot.create(:trueskill_game, max_number_of_teams: 4)
    record(game, [ada], [bob], [cy])

    get game_path(game)

    expect(text_of(response.body).first).to start_with("1st Ada 2nd Bob 3rd Cy")
  end

  it "labels the result form's slots by place when more than two teams can play" do
    game = FactoryBot.create(:trueskill_game, max_number_of_teams: 3)

    get new_game_result_path(game)

    labels = Nokogiri::HTML(response.body).css("#form-results label").map { |label| label.text.squish }
    expect(labels).to eq(%w[1st 2nd 3rd])
  end

  it "joins teammates with & so the teams are clear" do
    game = FactoryBot.create(:trueskill_game, max_number_of_players_per_team: 2)
    record(game, [ada, bob], [cy, di])

    get game_path(game)

    expect(text_of(response.body).first).to start_with("Ada & Bob defeats Cy & Di")
  end

  it "says a two-team draw is a tie" do
    game = FactoryBot.create(:elo_game, allow_ties: true)
    record(game, [ada], [bob], tie: true)

    get game_path(game)

    expect(text_of(response.body).first).to start_with("Ada ties Bob")
  end
end
