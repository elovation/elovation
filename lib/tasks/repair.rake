namespace :repair do
  task ratings: :environment do
    Game.all.each do |game|
      puts "calculating ratings for #{game.id} #{game.name}"
      puts "before: "
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - state: #{rating.state}"
      end

      game.recalculate_ratings!

      puts "after: "
      game.all_ratings.each do |rating|
        puts "#{rating.player.name} - value: #{rating.value} - state: #{rating.state}"
      end
    end
  end
end
