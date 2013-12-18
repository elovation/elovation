index = 0
json.array! @ratings do |rating|
  json.rank 	index += 1
  json.name 	rating.player.name
  json.rating rating.value
  json.gravatar_url gravatar_url(rating.player, :size => 40)
end