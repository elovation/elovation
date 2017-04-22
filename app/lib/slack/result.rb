module Slack
  class Result
    def self.create(payload)
      data = JSON.parse(URI.decode(payload['actions'][0]['selected_options'][0]['value']))
      game = Game.find(data['game_id'])
      result = { teams: {} }
      data['teams'].each_with_index do |team, index|
        result[:teams][index] = { players: team['players'].map { |player| player['id'] }, relation: team['relation'] }
      end
      response = ResultService.create(game, result)
      message = response.success? ? 'Success!' : response.result.errors.full_messages.join("\n")
      ApplicationController.render(template: 'slack/results/create.json', layout: false, assigns: { message: message })
    end
  end
end
