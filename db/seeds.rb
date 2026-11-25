# frozen_string_literal: true

# Demo data: six months of office play across several games, for trying the
# app locally and for the README screenshots (see bin/screenshots).
#
#   bin/rails db:seed
#
# Development only: db:prepare runs this file whenever it creates a database,
# so outside development (a fresh test database, or a first deploy) it does
# nothing.
#
# The data is deterministic: the same players play the same results every
# time, at the same offsets from the moment it's seeded (or from SCREENSHOT_TIME,
# which bin/screenshots sets). Results are recorded through
# ResultService at the time they were played, as if entered live. Refuses to
# run on a database that already has results.

require 'active_support/testing/time_helpers'

module DemoData
  extend ActiveSupport::Testing::TimeHelpers

  class SeedError < StandardError; end

  DAYS = 182
  RANDOM = Random.new(2026)

  # name, email?, skill (hidden, drives who wins), joined (days into the six
  # months), left (days in, or nil if still playing)
  PLAYERS = [
    ['Ada Okafor', true, 1.6, 0, nil],
    ['Ben Carter', false, 0.4, 0, nil],
    ['Chen Wei', true, 1.1, 0, nil],
    ['Dmitri Volkov', false, 0.9, 0, nil],
    ['Esi Mensah', true, -0.2, 0, nil],
    ['Farah Haddad', false, 0.7, 0, nil],
    ['Gus Lindqvist', true, -0.6, 0, nil],
    ['Hiroko Tanaka', false, 1.3, 0, nil],
    ['Isabel Moreno', true, 0.0, 0, nil],
    ['Jonas Becker', false, -1.0, 0, 120],
    ['Kavya Iyer', true, 0.8, 0, nil],
    ['Liam O\'Connor', false, -0.3, 0, nil],
    ['Maya Cohen', true, 0.5, 10, nil],
    ['Nikolai Petrov', false, -0.8, 0, 90],
    ['Olivia Brown', true, 0.2, 0, nil],
    ['Priya Nair', false, 1.0, 25, nil],
    ['Quentin Dubois', true, -0.4, 0, nil],
    ['Rosa Alvarez', false, 0.3, 40, nil],
    ['Samir Khan', true, -0.1, 0, nil],
    ['Tamsin Hughes', false, 0.6, 0, 150],
    ['Uchenna Eze', true, 1.4, 70, nil],
    ['Valentina Rossi', false, -0.7, 0, nil],
    ['Wiremu Ngata', true, 0.1, 100, nil],
    ['Xiao Ling', false, -1.2, 130, nil],
    ['Yusuf Demir', true, 0.4, 160, nil],
    ['Bartholomew Montgomery-Fitzwilliam III', false, -0.5, 0, nil],
    ['Zoe Park', true, 0.0, 175, nil]
  ].freeze

  # Games with their own theme; the rest use the site's.
  THEMES = { 'Ping Pong' => 'table-tennis', 'Foosball' => 'foosball', 'Chess' => 'chess' }.freeze

  # name, rating system, teams, players per team, ties, results per weekday
  GAMES = [
    ['Ping Pong', 'elo', 2..2, 1..1, false, 4.0],
    ['Foosball', 'trueskill', 2..2, 2..2, false, 3.0],
    ['Chess', 'elo', 2..2, 1..1, true, 1.2],
    ['Darts', 'elo', 2..2, 1..1, false, 1.5],
    ['Mario Kart', 'trueskill', 2..4, 1..1, true, 1.5],
    ['Rocket League', 'trueskill', 2..2, 1..3, false, 0.8],
    ['Catan', 'trueskill', 3..4, 1..1, false, 0.3],
    ['Cornhole', 'elo', 2..2, 1..1, true, 0.0]
  ].freeze

  def self.run
    abort 'The database already has results. Run bin/rails db:reset to start again with demo data.' if Result.exists?

    now = (ENV['SCREENSHOT_TIME'] ? Time.zone.parse(ENV['SCREENSHOT_TIME']) : Time.current).change(sec: 0)
    start = now - (DAYS + 1).days
    players = create_players(start)
    games = create_games(start, now)

    count = 0
    DAYS.times do |day|
      next if day % 7 >= 5 # the weekend

      present = players.select { |player| player[:joined] <= day && (player[:left].nil? || player[:left] > day) }
      games.each do |game|
        results_on(game, start + (day + 1).days, friday: day % 7 == 4).each do |played_at|
          count += 1 if travel_to(played_at) { record(game, present) }
        end
      end
    end
    puts "Seeded #{Player.count} players, #{Game.count} games and #{count} results."
  end

  def self.create_players(start)
    PLAYERS.map do |name, email, skill, joined, left|
      record = travel_to(start + joined.days) do
        Player.create!(name: name, email: email ? "#{name.split.first.downcase}@example.com" : '')
      end
      { record: record, skill: skill, joined: joined, left: left }
    end
  end

  def self.create_games(start, now)
    GAMES.map do |name, rating_type, teams, players_per_team, ties, per_day|
      created = name == 'Cornhole' ? now - 3.days : start
      record = travel_to(created) do
        Game.create!(name: name, rating_type: rating_type, allow_ties: ties, theme: THEMES[name],
                     min_number_of_teams: teams.begin, max_number_of_teams: teams.end,
                     min_number_of_players_per_team: players_per_team.begin,
                     max_number_of_players_per_team: players_per_team.end)
      end
      { record: record, teams: teams, players_per_team: players_per_team, ties: ties, per_day: per_day }
    end
  end

  # Times within the nine hours before `day_end`, more on Fridays.
  def self.results_on(game, day_end, friday:)
    expected = game[:per_day] * (friday ? 1.5 : 1.0)
    count = expected.floor + (RANDOM.rand < expected % 1 ? 1 : 0)
    Array.new(count) { day_end - RANDOM.rand(9 * 60).minutes }.sort
  end

  def self.record(game, present)
    team_count = RANDOM.rand(game[:teams])
    team_size = RANDOM.rand(game[:players_per_team])
    return false if present.size < team_count * team_size

    teams = present.sample(team_count * team_size, random: RANDOM).each_slice(team_size).to_a
    ranked = teams.map { |team| [team, performance(team)] }.sort_by { |_, score| -score }

    params = ranked.each_with_index.to_h do |(team, score), index|
      following = ranked[index + 1]
      tie = game[:ties] && following && (score - following.last).abs < 0.15
      [index.to_s, { players: team.map { |player| player[:record].id.to_s }, relation: tie ? 'ties' : 'defeats' }]
    end

    response = ResultService.create(game[:record], teams: params)
    raise SeedError, "Couldn't record a #{game[:record].name} result: #{response.result.errors.full_messages}" unless response.success?

    true
  end

  # A team's performance in one game: its average skill plus luck.
  def self.performance(team)
    (team.sum { |player| player[:skill] } / team.size) + gaussian
  end

  def self.gaussian
    Math.sqrt(-2 * Math.log(1 - RANDOM.rand)) * Math.cos(2 * Math::PI * RANDOM.rand)
  end
end

DemoData.run if Rails.env.development?
