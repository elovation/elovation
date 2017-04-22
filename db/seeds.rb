# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

players = 5.times.map { FactoryGirl.create(:player) }
games = 5.times.map { FactoryGirl.create(:game) }

games.each do |game|
  14.times do
    winner = players[rand(5)]
    loser = players.reject { |p| p == winner }[rand(4)]

    # ResultService.create(game, winner_id: winner.id, loser_id: loser.id)
    ResultService.create(game, teams: { "0" => { players: [winner.id]} , "1" => {players: [loser.id]} })
  end
end

RatingHistoryEvent.all.each_with_index { |result, idx| result.update(created_at: DateTime.now - idx,updated_at: DateTime.now - idx)}
