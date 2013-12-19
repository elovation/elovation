module Api::V1
	class ActivitiesController < Controller
		respond_to :json

		def recent
			@activities = Game
				.find(params[:game_id])
				.recent_results
		end
	end
end