require "rails_helper"

RSpec.describe "Deleting a player", type: :request do
  let(:player) { FactoryBot.create(:player) }

  # Regression: the link used rails-ujs's method: :delete, which Turbo ignores,
  # so clicking Delete sent a GET and showed the player again.
  it "offers a Delete link that Turbo sends as a DELETE" do
    get player_path(player)

    link = response.body[%r{<a [^>]*href="#{player_path(player)}"[^>]*>Delete</a>}]

    expect(link).to include('data-turbo-method="delete"')
  end

  it "deletes the player and redirects with 303 to the players page, even for a Turbo request" do
    delete player_path(player), headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(players_url)
    expect(Player.exists?(player.id)).to be(false)
  end
end
