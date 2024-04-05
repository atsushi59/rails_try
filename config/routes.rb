Rails.application.routes.draw do

  
  get "up" => "rails/health#show", as: :rails_health_check
  root "static_pages#index"
  resources :users
  resources :tasks
  get '/styles.css', to: 'static#styles'
end
