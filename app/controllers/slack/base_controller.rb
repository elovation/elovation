module Slack
  class BaseController < ApplicationController
    before_action :verify_token, except: [:authorize]

    def action
      payload = JSON.parse(params[:payload]).with_indifferent_access
      case payload[:callback_id]
        when 'record_result'
          render json: Slack::Result.create(payload)
      end
    end

    def authorize
      client = Slack::Web::Client.new
      auth = client.oauth_access(client_id: ENV['APP_CLIENT_ID'],
                                 client_secret: ENV['APP_CLIENT_SECRET'],
                                 code: params[:code])
      SlackAuthorization.find_or_create_by!(slack_authorization_params(auth))
      render text: 'Authorized'
    end
    
    private

    def verify_token
      token = params[:token] || JSON.parse(params[:payload])['token']
      head :unauthorized unless token == ENV['COMPETE_APP_TOKEN']
    end

    def slack_authorization_params(auth)
      ActionController::Parameters.new(auth)
                                  .permit('access_token', 'scope', 'user_id', 'team_name', 'team_id')
    end
  end
end
