# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "static_pages#index"
  resources :users
  resources :tasks
  get "/styles.css", to: "static#styles"
  post "some_action", to: "some#some_action"
  post "search", to: "some#search"
  get "index", to: "some#index"

  get "/terms_of_service", to: "static_pages#terms_of_service"
  get "/privacy_policy", to: "static_pages#privacy_policy"
end
