json.array! @activities do |activity|
	message, index = "", 0

	activity.teams.each do |team|	
		message << team.players.map { |p| p.display_name(Player.new) }.join(' and ')
		message << " beat " if index == 0
		index += 1	
	end	

	json.message message
	json.time activity.created_at
end