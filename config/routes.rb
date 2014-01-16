Elovation::Application.routes.draw do
  devise_for :players

  namespace :api do
  	namespace :v1 do
			resources :games, only: :none do
				resources :ratings, only: :index do
					collection do
						get :top
					end
				end
				resources :activities, only: :none do
					collection do
						get :recent
					end
				end
			end
		end
	end

  resources :games do
    resources :results, :only => [:create, :destroy, :new]
    resources :ratings, :only => [:index]
  end

  resources :players do
    resources :games, :only => [:show], :controller => 'player_games'
  end

  root :to => 'dashboard#show'
end
