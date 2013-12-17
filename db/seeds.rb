default_password = 'password'

jkappers = Player.create({
	name: 'Joshua Kappers',
	email: 'jkappers@kalkomey.com',
	password: default_password
})

jkappers.admin = true;
jkappers.save

users = [
	"Jason Alexander",
	"Kevin Clark",
	"Mike Mayo",
	"Ado Bitar",
	"Aziz Punjani",
	"Jeremy Perez",
	"Chris Krailo",
	"Bradley Griffith",
	"Michael Criswell",
	"Andy Rutledge",
	"Edward Cossette",
	"Wes Johnson",
	"Ryan Rushing",
	"Jay Sparks"
].map do |name|
	parts = name.split(' ')
	email = "#{parts[0][0,1]}#{parts[1]}@kalkomey.com".downcase
	Player.create({
		name: name,
		email: email,
		password: default_password	
	})
end

Game.create({
	name: 'Ping Pong',
	rating_type: 'trueskill',
	min_number_of_teams: 2,
	max_number_of_teams: 2,
	min_number_of_players_per_team: 1,
	max_number_of_players_per_team: 2,
	allow_ties: false
})