Rails.application.routes.draw do
  root "home#index"

  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout",to: "sessions#destroy", as: :logout

  get "/trips/search", to: "trips#search", as: :search_trips

  get "/trips/:trip_id/seats", to: "trip_seats#show", as: :trip_seats

  post "/trips/:trip_id/holds", to: "holds#create", as: :trip_holds
  get "/holds/:id", to: "holds#show", as: :hold
  post "/holds/:id/confirm", to: "holds#confirm", as: :confirm_hold
  get "/bookings/:id", to: "bookings#show", as: :booking
  post "/bookings/:id/cancel", to: "bookings#cancel", as: :cancel_booking
  post "/bookings/:id/reschedule/:trip_id", to: "bookings#reschedule", as: :reschedule_booking
  get "/bookings/:id/reschedule", to: "bookings#reschedule_form", as: :reschedule_form
end
