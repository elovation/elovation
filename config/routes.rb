Elovation::Application.routes.draw do
  devise_for :players

  resources :games do
    resources :results, :only => [:create, :destroy, :new]
    resources :ratings, :only => [:index]
  end

  resources :players do
    resources :games, :only => [:show], :controller => 'player_games'
  end

  root :to => 'dashboard#show'
end
