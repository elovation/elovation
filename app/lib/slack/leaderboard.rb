module Slack
  class Leaderboard
    def self.show(payload)
      game = Game.find(payload['actions'][0]['selected_options'][0]['value'])
      rows = game.all_ratings.select(&:active?).map.with_index(1) do |rating, index|
          [index, rating.player.name, rating.value, rating.player.total_wins(rating.game), rating.player.results.for_game(rating.game).losses.size]
        end
      message = "```\n#{Terminal::Table.new :title => "#{game.name} Leaderboard", :headings => %w(# Name Ranking W L), :rows => rows}\n```"
      slack_client = Slack::Web::Client.new(token: SlackAuthorization.find_by(team_id: payload['team']['id']).access_token)
      slack_client.chat_postMessage(channel: payload['channel']['id'], text: message)
    end
  end
end
