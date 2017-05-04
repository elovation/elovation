require_relative 'decorators/result_decorator'

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
      players = data[:teams].map { |team| team[:players] }.flatten.map { |player| Player.find(player[:id]) }
      ::Result.transaction do
        previous_ratings = players.map { |player| player.current_rating_for(game) }
        response = ResultService.create(game, result)
        if response.success?
          slack_client.chat_postMessage(channel: payload['channel']['id'], text: public_success_message(game, players, data[:teams], previous_ratings))
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

      def public_success_message(game, players, teams, previous_ratings)
        players_with_rankings = players.map do |player|
          previous_rating = previous_ratings.find { |rating| rating[:player_id] == player.id }
          player.attributes.merge rating: player.rating_for(game), message: Slack::Decorators::RatingDecorator.new(player, previous_rating, game).message
        end.sort_by { |player| -player[:rating] }
        game_url = Rails.application.routes.url_helpers.game_url(game, host: ENV['HOST'])
        human_string(teams) + " at <#{game_url}|#{game.name}>\n" + players_with_rankings.map { |player| player[:message] }.join("\n")
      end
    end
  end
end
