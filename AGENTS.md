# AGENTS.md

Guidance for AI coding agents (and humans) working on Elovation: a small Rails app that tracks game results and rates players with Elo (1v1) or TrueSkill (teams).

## Fast test loop (preferred)

Ruby on the host via [asdf](https://asdf-vm.com), Postgres in Docker. A full run takes about 5 seconds.

One-time setup:

```bash
asdf plugin add ruby
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)" asdf install   # reads .tool-versions
gem install bundler -v "$(tail -1 Gemfile.lock | tr -d ' ')"
bundle install
docker compose up -d db
PGHOST=localhost RAILS_ENV=test bin/rails db:create db:schema:load
```

Every time:

```bash
docker compose up -d db                       # if not already running
PGHOST=localhost bundle exec rspec            # whole suite
PGHOST=localhost bundle exec rspec spec/models/rater_spec.rb:59   # one example
```

`PGHOST=localhost` is required because `config/database.yml` defaults the host to `db`, the Compose service name used inside containers.

If tests fail with "has already been taken" or unexpected record counts, the test database contains stale rows. Reset it with `PGHOST=localhost RAILS_ENV=test bin/rails db:schema:load`.

## Layout

- `app/models/rater.rb`: the rating algorithms (`EloRater`, `TrueSkillRater`). This is the core domain logic.
- `app/services/result_service.rb`: creating and deleting results. Only a game's most recent result can be deleted, and deleting it rewinds ratings.
- `app/models/game.rb`: games, their rater, and `recalculate_ratings!`.
- `spec/`: RSpec suite (models, controllers, helpers, services) using FactoryBot. The `test/` directory is unused Rails scaffolding.

## Conventions

- Write new specs with `expect` syntax. Legacy specs use `should`; both are enabled in `spec/spec_helper.rb`.
- Use `travel_to` (ActiveSupport) for time-dependent tests. Don't add Timecop.
- Each example runs in a transaction (`use_transactional_fixtures`), so don't add DatabaseCleaner.
- Deleting results must keep ratings consistent. Don't add cascading deletes that remove results without rewinding or recalculating ratings.
- Run `bundle exec rubocop` before pushing. CI fails on any offense.

## CI

`.github/workflows/ci.yml` runs RSpec and Rubocop against Postgres 17 on every push and pull request to `main`. A failing test or a Rubocop offense fails the build.

SonarCloud analysis is not part of this workflow. The SonarCloud GitHub app runs it automatically (Automatic Analysis) and reports a "SonarCloud Code Analysis" check on each pull request. Don't add a scanner step to CI: SonarCloud rejects CI-based analysis while Automatic Analysis is enabled.
