Rails.application.routes.draw do
  root "home#index"

  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout",to: "sessions#destroy", as: :logout

  get "/trips/search", to: "trips#search", as: :search_trips
end