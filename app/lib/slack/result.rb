module Slack
  class Result
    def self.create(payload)
      data = JSON.parse(URI.decode(payload['actions'][0]['selected_options'][0]['value'])).deep_symbolize_keys
      game = Game.find(data[:game_id])
      slack_client = Slack::Web::Client.new(token: SlackAuthorization.find_by(team_id: payload['team']['id']).access_token)
      return slack_client.chat_postMessage(channel: payload['user']['id'], text: "#{game.name} is inactive") if game.inactive?
      result = { teams: {} }
      data[:teams].each_with_index do |team, index|
        result[:teams][index] = { players: team[:players].map { |player| player[:id] }, relation: team[:relation] }
      end
      ::Result.transaction do
        response = ResultService.create(game, result)
        if response.success?
          slack_client.chat_postMessage(channel: payload['channel']['id'], text: public_success_message(game, data[:teams]))
        else
          slack_client.chat_postMessage(channel: payload['user']['id'], text: response.result.errors.full_messages.join("\n"))
        end
      end
    end

    def self.human_string(teams)
      teams.map { |team| team[:players].map { |player| player[:name] }.to_sentence + " #{team[:relation]}" }.join(' ').strip
    end

    class << self

      private

      def public_success_message(game, teams)
        ratings = game.all_ratings.select(&:active?)
        players_with_rankings = teams.map { |team| team[:players] }.flatten.map do |player|
          ranking = ratings.index { |rating| rating.player_id == player[:id]} + 1
          rating = Player.find(player[:id]).ratings.find_by_game_id(game).value
          player_url = Rails.application.routes.url_helpers.player_url(player[:id], host: ENV['HOST'])
          player.merge ranking: ranking, message: "<#{player_url}|#{player[:name]}> is now in #{ranking.ordinalize} place with a rating of #{rating}"
        end.sort_by { |player| player[:ranking] }
        game_url = Rails.application.routes.url_helpers.game_url(game, host: ENV['HOST'])
        human_string(teams) + " at <#{game_url}|#{game.name}>\n" + players_with_rankings.map { |player| player[:message] }.join("\n")
      end
    end
  end
end
