Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games do
    resources :results, only: [:create, :destroy, :new]
  end

  resources :players

  root "dashboard#index"
end
