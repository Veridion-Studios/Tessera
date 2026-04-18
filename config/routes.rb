Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  # GitHub OAuth
  get  "/auth/github/callback", to: "oauth#github"
  post "/auth/github", as: :github_auth

  root "pages#home"
  get "/join", to: "pages#join", as: :join

  # Role picker
  get  "/pick-dashboard", to: "dashboard#pick",   as: :pick_dashboard
  post "/pick-dashboard", to: "dashboard#switch",  as: :switch_dashboard

  # Dashboards
  get "/dashboard/developer", to: "dashboard#developer", as: :developer_dashboard
  get "/dashboard/client",    to: "dashboard#client",    as: :client_dashboard

  # Adding a second role — GET for confirmation page, POST to actually add
  get  "/account/add-role", to: "account#confirm_role",  as: :confirm_add_role
  post "/account/add-role", to: "account#add_role",      as: :add_role

  # Developer onboarding wizard
  namespace :onboarding do
    get  "portfolio",        to: "portfolio#show",   as: :portfolio
    post "portfolio",        to: "portfolio#create"
    get  "identity",         to: "identity#show",    as: :identity
    post "identity/start",   to: "identity#start",   as: :identity_start
    get  "identity/refresh", to: "identity#refresh", as: :identity_refresh
    get  "connect",          to: "connect#show",     as: :connect
    post "connect/start",    to: "connect#start",    as: :connect_start
    get  "connect/refresh",  to: "connect#refresh",  as: :connect_refresh
    get  "complete",         to: "complete#show",    as: :complete
  end

  # Admin panel
  namespace :admin do
    root "dashboard#index"
    resources :portfolio_submissions, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end
    resources :users, only: [:index, :show]
  end
end