Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, skip: :all

  namespace :api do
    post   "signup", to: "auth#signup"
    post   "login",  to: "auth#login"
    delete "logout", to: "auth#logout"
    get    "me",     to: "auth#me"

    resources :messages, only: [:index, :create] do
      collection do
        post :status_callback
      end
    end
  end
end
