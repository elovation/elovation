source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# https://github.com/iain/elo
gem 'elo'
# https://github.com/saulabs/trueskill
gem 'trueskill', github: 'saulabs/trueskill', require: 'saulabs/trueskill'

# https://chartkick.com/
gem 'chartkick'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # https://rspec.info/documentation/6.0/rspec-rails/
  gem 'rspec-rails', '~> 6.0.0'

  # https://github.com/thoughtbot/factory_bot
  gem 'factory_bot_rails'

  # https://github.com/faker-ruby/faker
  gem 'faker'

  # https://github.com/rubocop/rubocop
  gem 'rubocop'
end

group :development do
  # https://github.com/BetterErrors/better_errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # https://github.com/fly-apps/dockerfile-rails
  gem 'dockerfile-rails', '>= 1.5'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  # https://github.com/simplecov-ruby/simplecov
  gem 'simplecov'
  # https://github.com/codeclimate-community/simplecov_json_formatter
  gem 'simplecov_json_formatter'
end

gem 'sentry-ruby', '~> 5.11'

gem 'sentry-rails', '~> 5.11'
