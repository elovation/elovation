Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources(:games) do
    resources(:results, only: %i[create destroy new])
    resources(:ratings, only: [:index])
  end

  resources(:players) do
    resources(:games, only: [:show], controller: "player_games")
  end

  root("dashboard#index")
end
