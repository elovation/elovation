require "rails_helper"

RSpec.describe "Retracting a result", type: :request do
  let(:game) { FactoryBot.create(:elo_game) }
  let(:winner) { FactoryBot.create(:player) }
  let(:loser) { FactoryBot.create(:player) }
  let!(:result) do
    ResultService.create(game, teams: { "0" => { players: [winner.id.to_s], relation: "defeats" }, "1" => { players: [loser.id.to_s] } }).result
  end

  # Regression: the link used rails-ujs's method: :delete, which Turbo ignores,
  # so clicking Delete sent a GET and returned 404.
  it "offers a Delete link that Turbo sends as a DELETE" do
    get game_path(game)

    link = response.body[%r{<a [^>]*href="#{game_result_path(game, result)}"[^>]*>Delete</a>}]

    expect(link).to include('data-turbo-method="delete"')
  end

  it "retracts the result and redirects with 303 so the browser follows up with a GET" do
    delete game_result_path(game, result), headers: { "Referer" => game_url(game) }

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(game_url(game))
    expect(Result.exists?(result.id)).to be(false)
    expect(Rating.where(game: game)).to be_empty
  end
end
