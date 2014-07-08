source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '~> 4.1.4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'sass-rails', '~> 4.0.3'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'dynamic_form'
gem 'elo'
gem 'trueskill', github: 'saulabs/trueskill', require: 'saulabs/trueskill'

group :production do
  gem 'rails_12factor'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :development, :test do
  # App preloading
  gem 'spring'
  gem 'spring-commands-rspec'
  # Pry stuff
  gem 'pry'
  gem 'pry-coolline'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :test do
  gem 'rspec-rails', '~> 2.14.2'
  gem 'mocha'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'timecop'
end
