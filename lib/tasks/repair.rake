namespace :repair do
  task ratings: :environment do
    Game.all.each do |game|
      puts "calculating ratings for #{game.id} #{game.name}"
      puts "before: "
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - (mean: #{rating.trueskill_mean} deviation: #{rating.trueskill_deviation})"
      end

      game.recalculate_ratings!

      puts "after: "
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - (mean: #{rating.trueskill_mean} deviation: #{rating.trueskill_deviation})"
      end
    end
  end
end
