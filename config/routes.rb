Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  # GitHub OAuth
  get  "/auth/github/callback", to: "oauth#github"
  post "/auth/github", as: :github_auth

  root "pages#home"
  get "/join", to: "pages#join", as: :join

  # Developer onboarding wizard
  namespace :onboarding do
    get  "portfolio",         to: "portfolio#show",    as: :portfolio
    post "portfolio",         to: "portfolio#create"
    get  "identity",          to: "identity#show",     as: :identity
    post "identity/start",    to: "identity#start",    as: :identity_start
    get  "identity/refresh",  to: "identity#refresh",  as: :identity_refresh
    get  "connect",           to: "connect#show",      as: :connect
    post "connect/start",     to: "connect#start",     as: :connect_start
    get  "connect/refresh",   to: "connect#refresh",   as: :connect_refresh
    get  "complete",          to: "complete#show",     as: :complete
  end

  # Dashboards
  get "/dashboard", to: "dashboard#show", as: :dashboard
end