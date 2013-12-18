module Api::V1
	class RatingsController < Controller
		respond_to :json

		def top
			@ratings = Game				
				.find(params[:game_id])
			 	.all_ratings
				.select(&:active?)
		end
	end
end