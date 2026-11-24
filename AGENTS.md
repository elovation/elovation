# AGENTS.md

Guidance for AI coding agents (and humans) working on Elovation: a small Rails app that tracks game results and rates players with Elo (1v1) or TrueSkill (teams).

Stack: Ruby 4.0, Rails 8.1, PostgreSQL 17, Propshaft with importmap, Turbo/Stimulus, and RSpec.

## Fast local loop (preferred)

Ruby on the host via [asdf](https://asdf-vm.com), Postgres in Docker. Running all the checks takes about 10 seconds.

One-time setup:

```bash
asdf plugin add ruby
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)" asdf install   # reads .tool-versions
bundle install
docker compose up -d db
PGHOST=localhost bin/rails db:prepare                 # development database
PGHOST=localhost RAILS_ENV=test bin/rails db:prepare  # test database
```

Every time:

```bash
docker compose up -d db                                          # if not already running
PGHOST=localhost bin/ci                                          # everything CI runs: rubocop, importmap audit, rspec
PGHOST=localhost bundle exec rspec                               # just the specs
PGHOST=localhost bundle exec rspec spec/models/rater_spec.rb:59  # one example
PGHOST=localhost bin/dev                                         # app on http://localhost:3000
```

`PGHOST=localhost` is required because `config/database.yml` defaults the host to `db`, the Compose service name used inside containers.

If tests fail with "has already been taken" or unexpected record counts, the test database contains stale rows. Reset it with `PGHOST=localhost RAILS_ENV=test bin/rails db:schema:load`.

## Layout

Read `CONTEXT.md` first. It defines the domain terms used in code and specs: rating system, rating state, standing, leaderboard, replay.

- `app/models/rating_systems.rb`: the rating-system interface (and `Standing`, `Placing`, `Format`).
- `app/models/rating_systems/`: one pure module per rating system (`Elo`, `TrueSkill`), plus `Replay`. No database access. Tested in `spec/models/rating_systems/` against the shared contract in `spec/support/rating_system_contract.rb`.
- `app/models/leaderboard.rb`: the only code that writes ratings (`record`, `retract`, `rebuild`, `preview`). Recording a result is one step of a rebuild.
- `app/services/result_service.rb`: turns the result form into a Result, then records it on the game's leaderboard. Only a result that is the latest for all its players can be deleted.
- `vendor/trueskill/`: the vendored, unmaintained `saulabs/trueskill` library, loaded only by `RatingSystems::TrueSkill`. See `VENDORED.md` there before changing it.
- `config/ci.rb`: the steps `bin/ci` runs, locally and in GitHub Actions.
- `spec/`: RSpec suite (models, controllers, helpers, services, requests) using FactoryBot.

## Conventions

- Write specs with `expect` syntax. The `should` syntax is disabled in `spec/spec_helper.rb`.
- Use `travel_to` (ActiveSupport) for time-dependent tests. Don't add Timecop.
- Each example runs in a transaction (`use_transactional_fixtures`), so don't add DatabaseCleaner.
- Ratings are derived from results. Write them only through `Leaderboard`, and don't add cascading deletes that remove results without retracting them.
- Rating changes must not move existing numbers unintentionally. `spec/models/rating_golden_spec.rb` pins live ratings recorded from the original implementation; if it fails, treat it as a behaviour change and call it out.
- To add a rating system, follow "Adding a rating system" in the README.
- Only the Rails frameworks the app uses are loaded (see `config/application.rb`). Active Storage, Action Mailbox and Action Text are deliberately excluded.
- Run `bin/ci` before pushing. CI fails on any Rubocop offense.

## CI

`.github/workflows/ci.yml` runs `bin/ci` against Postgres 17 on every push and pull request to `main`. A failing step fails the build. To add a check, add it to `config/ci.rb` rather than the workflow, so local runs and CI stay identical.

SonarCloud analysis is not part of this workflow. The SonarCloud GitHub app runs it automatically (Automatic Analysis) and reports a "SonarCloud Code Analysis" check on each pull request. Don't add a scanner step to CI: SonarCloud rejects CI-based analysis while Automatic Analysis is enabled. Configure analysis (for example, exclusions) in `.sonarcloud.properties`. Generated (`public/`) and vendored (`vendor/`) code is excluded.
