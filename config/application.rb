require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Elovation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    if ENV['BASIC_AUTH'] == "true"
      config.middleware.use(::Rack::Auth::Basic) do |u, p|
        [u, p] == [ENV['BASIC_AUTH_USER'], ENV['BASIC_AUTH_PASSWORD']]
      end
    end
  end
end
