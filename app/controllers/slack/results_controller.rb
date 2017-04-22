module Slack
  class ResultsController < BaseController
    SLACK_USER_ID_REGEX = /<@(U[A-Z0-9]+)\|[A-z0-9_-]+>/

    def new
      @games = Game.all
      @teams = params[:text].split(/(?<=beat|tied)/).map do |team|
        player_ids = team.scan(SLACK_USER_ID_REGEX).flatten
        players = player_ids.map do |player_id|
          player = Player.find_or_create_from_slack(params[:team_id], player_id)
          { name: player.name, id: player.id }
        end
        relation = if team.include?('beat')
                     :defeats
                   elsif team.include?('tied')
                     'ties'
                   end
        { players: players, relation: relation }
      end
    end
  end
end

