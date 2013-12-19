module Api::V1
	class RatingsController < Controller
		respond_to :json

		def index
			@ratings = Rating
			 	.includes(:player)
				.where(game_id: params[:game_id])
				.order("value DESC")
		end

		def top
			@ratings = Rating
			 	.includes(:player)
				.where(game_id: params[:game_id])
				.order("value DESC")
				.limit(10)
		end
	end
end