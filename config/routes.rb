Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  get "login", to: redirect("/session/new")
  get "signup", to: redirect("/registration/new")

  resources :posts do
    resources :comments, only: %i[ create destroy ]
  end
  resources :users, only: :show

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render the dynamic PWA manifest from app/views/pwa/manifest.json.erb.
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "posts#index"
end
