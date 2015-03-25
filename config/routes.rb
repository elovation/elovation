Elovation::Application.routes.draw do
  resources :games do
    resources :results, only: [:create, :destroy, :new]
    resources :ratings, only: [:index] do
      collection do
        get 'by_days'
      end
    end
  end

  resources :players do
    resources :games, only: [:show], controller: 'player_games'
  end

  resources :flairs

  get '/dashboard' => 'dashboard#show', as: :dashboard
  root to: 'dashboard#show'
end
