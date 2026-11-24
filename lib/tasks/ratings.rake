# frozen_string_literal: true

namespace :ratings do
  desc 'Show the ratings a game would have under any rating system, without saving: rails "ratings:preview[GAME_ID,trueskill]"'
  task :preview, %i[game_id rating_system] => :environment do |_task, args|
    game = Game.find(args.fetch(:game_id))
    system = RatingSystems.fetch(args[:rating_system] || game.rating_type) or
      abort "Unknown rating system #{args[:rating_system].inspect}. Choose one of: #{RatingSystems.keys.join(', ')}"
    names = Player.where(id: game.results.joins(teams: :players).select('players.id')).pluck(:id, :name).to_h

    puts "#{game.name}: #{game.results.count} results rated with #{system.description}"
    game.leaderboard.preview(system).each_with_index do |entry, index|
      puts format('%<position>3d. %<name>-30s %<score>6d  %<state>s',
                  position: index + 1, name: names[entry.player_id], score: entry.score, state: entry.state.to_json)
    end
  end
end
