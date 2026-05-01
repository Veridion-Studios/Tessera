Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions:      "users/sessions",
    registrations: "users/registrations"
  }

  get "about", to: "pages#about"

  # GitHub OAuth
  get  "/auth/github/callback", to: "oauth#github"
  post "/auth/github", as: :github_auth

  root "pages#home"
  get "/join", to: "pages#join", as: :join

  # Passkey management (authenticated)
  scope "/account" do
    get "passkeys/prompt", to: "passkeys#prompt", as: :passkey_prompt
    get    "passkeys",          to: "passkeys#index",   as: :passkeys
    post   "passkeys/options",  to: "passkeys#options", as: :passkey_options
    post   "passkeys",          to: "passkeys#create",  as: :create_passkey
    delete "passkeys/:id",      to: "passkeys#destroy", as: :passkey
  end

  # Passkey sign-in (public)
  post "/auth/passkeys/options", to: "passkeys#session_options", as: :passkey_session_options
  post "/auth/passkeys",         to: "passkeys#session_create",  as: :passkey_session_create

  # Account settings
  get   "/account/settings",        to: "account#settings",        as: :account_settings
  patch "/account/settings/email",  to: "account#update_email",    as: :account_update_email
  patch "/account/settings/password", to: "account#update_password", as: :account_update_password
  delete "/account",                to: "account#destroy",          as: :account_destroy

  # Role picker
  get  "/pick-dashboard", to: "dashboard#pick",   as: :pick_dashboard
  post "/pick-dashboard", to: "dashboard#switch",  as: :switch_dashboard

  # Dashboards
  get "/dashboard/developer", to: "dashboard#developer", as: :developer_dashboard
  get "/dashboard/client",    to: "dashboard#client",    as: :client_dashboard

  # Client identity verification
  namespace :client do
    get  "identity",         to: "identity#show",    as: :identity
    post "identity/start",   to: "identity#start",   as: :identity_start
    get  "identity/refresh", to: "identity#refresh", as: :identity_refresh
  end

  # Adding a second role
  get  "/account/add-role", to: "account#confirm_role", as: :confirm_add_role
  post "/account/add-role", to: "account#add_role",     as: :add_role

  # Developer onboarding wizard
  namespace :onboarding do
    get  "portfolio",        to: "portfolio#show",   as: :portfolio
    post "portfolio",        to: "portfolio#create"
    get  "portfolio/github_repos", to: "portfolio#github_repos", as: :portfolio_github_repos
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