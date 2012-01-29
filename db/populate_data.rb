players = 5.times.map { FactoryGirl.create(:player) }
games = 5.times.map { FactoryGirl.create(:game) }

games.each do |game|
  3.times do
    winner = players[rand(5)]
    loser = players.reject { |p| p == winner }[rand(4)]

    FactoryGirl.create(:result, :game => game, :winner => winner, :loser => loser)
  end
end
