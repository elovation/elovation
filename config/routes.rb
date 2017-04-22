Elovation::Application.routes.draw do
  resources :games do
    resources :results, only: [:create, :destroy, :new]
    resources :ratings, only: [:index]
  end

  resources :players do
    resources :games, only: [:show], controller: 'player_games'
  end

  get '/dashboard' => 'dashboard#show', as: :dashboard
  root to: 'dashboard#show'

  namespace :slack do
    resources :results, only: [] do
      collection do
        post 'new', as: 'new'
      end
    end

    post '/action', to: 'base#action'
    get '/authorize', to: 'base#authorize'
  end
end
