source 'https://rubygems.org'

ruby '2.4.1'

gem 'rails', '~> 5.0'

gem 'pg'

gem 'sass-rails', '~> 5.0'
gem 'jquery-rails'
gem 'uglifier'
gem 'chartkick'

gem 'dynamic_form'
gem 'elo'
gem 'trueskill', github: 'saulabs/trueskill', require: 'saulabs/trueskill'
gem 'slack-ruby-client'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'mocha'
  gem 'rspec-rails', '~> 3.5'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end
