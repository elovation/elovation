#!/bin/sh
set -e

echo "Database.yml"
cat config/database.yml

echo "Bundle config"
bundle config github.https true

echo "Install gems"
bundle install --path /var/bundle --without development test

echo "Precompile assets"
bundle exec rake assets:precompile

echo "Sets rake secret"
export SECRET_KEY_BASE=`bundle exec rake secret`

echo "Clearing logs"
bin/rake log:clear

echo "Run migrations"
bundle exec rake db:migrate RAILS_ENV=production_admin

echo "Removing contents of tmp dirs"
bin/rake tmp:clear

exec "$@"