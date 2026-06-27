Rails.application.routes.draw do
  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  # Register the Devise :user mapping (gives us current_user / authenticate_user!)
  # but skip Devise's default HTML routes — we use our own JSON auth endpoints.
  devise_for :users, skip: :all

  namespace :api do
    # Auth (Bonus 1)
    post   "signup", to: "auth#signup"
    post   "login",  to: "auth#login"
    delete "logout", to: "auth#logout"
    get    "me",     to: "auth#me"

    # SMS
    #   POST /api/messages                 -> send + persist an SMS
    #   GET  /api/messages                 -> list the current user's messages
    #   POST /api/messages/status_callback -> Twilio delivery webhook (Bonus 3)
    resources :messages, only: [:index, :create] do
      collection do
        post :status_callback
      end
    end
  end
end
