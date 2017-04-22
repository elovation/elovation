module Slack
  class BaseController < ApplicationController
    def authorize
      client = Slack::Web::Client.new
      auth = client.oauth_access(client_id: ENV['APP_CLIENT_ID'],
                                 client_secret: ENV['APP_CLIENT_SECRET'],
                                 code: params[:code])
      SlackAuthorization.find_or_create_by!(slack_authorization_params(auth))
      render text: 'Authorized'
    end
    
    private

    def slack_authorization_params(auth)
      ActionController::Parameters.new(auth)
                                  .permit('access_token', 'scope', 'user_id', 'team_name', 'team_id')
    end
  end
end
