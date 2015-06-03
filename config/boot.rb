require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'rails/commands/server'
module Rails
  class Server
    alias :default_options_alias :default_options
    def default_options
      default_port = ENV['RAILS_ENV'] == 'production' ? 3000 : 3001
      default_options_alias.merge!(:Port => default_port)
    end
  end
end
