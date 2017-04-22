module Slack
  class Result
    def self.create(payload)
      data = JSON.parse(URI.decode(payload['actions'][0]['selected_options'][0]['value'])).deep_symbolize_keys
      game = Game.find(data[:game_id])
      result = { teams: {} }
      data[:teams].each_with_index do |team, index|
        result[:teams][index] = { players: team[:players].map { |player| player[:id] }, relation: team[:relation] }
      end
      ::Result.transaction do
        response = ResultService.create(game, result)
        if response.success?
          slack_client = Slack::Web::Client.new(token: SlackAuthorization.find_by(team_id: payload['team']['id']).access_token)
          slack_client.chat_postMessage(channel: payload['channel']['id'], text: human_string(data[:teams]) + " at #{game.name}.")
          'Result recorded!'
        else
          response.result.errors.full_messages.join("\n")
        end
      end
    end

    def self.human_string(teams)
      teams.map { |team| team[:players].map { |player| player[:name] }.to_sentence + " #{team[:relation]}" }.join(' ').strip
    end
  end
end
