# frozen_string_literal: true

namespace :repair do
  desc 'Rebuild every game\'s ratings from its results'
  task ratings: :environment do
    Game.all.each do |game|
      puts "calculating ratings for #{game.id} #{game.name}"
      puts 'before: '
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - state: #{rating.state}"
      end

      game.leaderboard.rebuild

      puts 'after: '
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - state: #{rating.state}"
      end
    end
  end
end
