# frozen_string_literal: true

# Run using bin/ci (needs Postgres: `docker compose up -d db`, and PGHOST=localhost outside Docker)

CI.run do
  step 'Style: Ruby', 'bin/rubocop'
  step 'Security: Importmap vulnerability audit', 'bin/importmap audit'
  step 'Setup: Test database', 'env RAILS_ENV=test bin/rails db:prepare'
  step 'Tests: RSpec', 'bundle exec rspec'
end
