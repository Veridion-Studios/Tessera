Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions:      "users/sessions",
    registrations: "users/registrations"
  }

  get "about", to: "pages#about"

  get "/error/:id", to: "errors#show", as: :error

  # GitHub OAuth
  get  "/auth/github/callback", to: "oauth#github"
  post "/auth/github", as: :github_auth

  root "pages#home"
  get "/join",   to: "pages#join",   as: :join
  get "/status", to: "pages#status", as: :status_page

  # Legal pages
  get "/legal/terms",        to: "pages#terms",          as: :legal_terms
  get "/legal/privacy",      to: "pages#privacy",        as: :legal_privacy
  get "/legal/escrow-policy", to: "pages#escrow_policy", as: :legal_escrow_policy
  get "/legal/cookies",      to: "pages#cookies",        as: :legal_cookies
  get "/legal/acceptable-use", to: "pages#acceptable_use", as: :legal_acceptable_use

  # Public gallery & profiles
  get "/gallery",           to: "gallery#index",  as: :gallery
  get "/profile/:username", to: "profiles#show",  as: :developer_profile

  # Passkeys
  scope "/account" do
    get    "passkeys/prompt",  to: "passkeys#prompt",    as: :passkey_prompt
    get    "passkeys",         to: "passkeys#index",      as: :passkeys
    post   "passkeys/options", to: "passkeys#options",    as: :passkey_options
    post   "passkeys",         to: "passkeys#create",     as: :create_passkey
    delete "passkeys/:id",     to: "passkeys#destroy",    as: :passkey
  end

  post "/auth/passkeys/options", to: "passkeys#session_options", as: :passkey_session_options
  post "/auth/passkeys",         to: "passkeys#session_create",  as: :passkey_session_create

  # Account
  get    "/account/settings",          to: "account#settings",        as: :account_settings
  patch  "/account/settings/email",    to: "account#update_email",    as: :account_update_email
  patch  "/account/settings/password", to: "account#update_password", as: :account_update_password
  delete "/account",                   to: "account#destroy",         as: :account_destroy
  get    "/account/add-role",          to: "account#confirm_role",    as: :confirm_add_role
  post   "/account/add-role",          to: "account#add_role",        as: :add_role

  # Dashboards
  get  "/pick-dashboard",      to: "dashboard#pick",      as: :pick_dashboard
  post "/pick-dashboard",      to: "dashboard#switch",    as: :switch_dashboard
  get  "/dashboard/developer", to: "dashboard#developer", as: :developer_dashboard
  get  "/dashboard/client",    to: "dashboard#client",    as: :client_dashboard

  # Developer dashboard
  scope "/dashboard/developer", as: "developer" do
    get "portfolio",              to: "developer/portfolio#index",          as: :portfolio
    patch "portfolio/profile",    to: "developer/portfolio#update_profile", as: :update_profile
    get "projects",               to: "developer/projects#index",           as: :projects
    get "projects/:id",           to: "developer/projects#show",            as: :project
    get "projects/:id/escrow_status", to: "developer/projects#escrow_status", as: :project_escrow_status
    get "devlogs",                to: "developer/devlogs#index",            as: :devlogs
    get "earnings",               to: "developer/earnings#index",           as: :earnings
    get "crm",                    to: "developer/crm#index",                as: :crm
    get "linear/connect",         to: "developer/linear#connect",           as: :linear_connect
    get "linear/callback",        to: "developer/linear#callback",          as: :linear_callback
    delete "linear/disconnect",   to: "developer/linear#disconnect",        as: :linear_disconnect
    get "linear/issues",          to: "developer/linear#issues",            as: :linear_issues
    post "devlogs",               to: "developer/devlogs#create"

    # Invoicing
    resources :invoices, only: [:index, :new, :create, :show, :edit, :update, :destroy],
              controller: "developer/invoices" do
      member do
        post :send_invoice
        post :mark_paid
        post :void
      end
    end

    # Subscriptions / retainers
    resources :subscriptions, only: [:index, :new, :create, :show, :edit, :update, :destroy],
              controller: "developer/subscriptions" do
      member do
        post :cancel
        post :pause
        post :resume
      end
    end
  end

  # Notifications
  get  "/notifications",          to: "notifications#index",      as: :notifications
  post "/notifications/mark_all", to: "notifications#mark_all",   as: :mark_all_notifications
  post "/notifications/:id/read", to: "notifications#mark_read",  as: :mark_notification_read

  scope "/dashboard" do
    namespace :client do
      resources :quotes, only: [:index, :new, :create, :show] do
        member do
          post :withdraw
          post :message
        end
      end
    end

    namespace :developer do
      resources :quotes, only: [:index, :show] do
        member do
          post :accept
          post :decline
          post :counter
          post :message
        end
      end
    end
  end

  # Onboarding
  namespace :onboarding do
    get  "identity",         to: "identity#show",    as: :identity
    post "identity/start",   to: "identity#start",   as: :identity_start
    get  "identity/refresh", to: "identity#refresh", as: :identity_refresh

    namespace :developer do
      get  "portfolio",              to: "portfolio#show",         as: :portfolio
      post "portfolio",              to: "portfolio#create"
      get  "portfolio/github_repos", to: "portfolio#github_repos", as: :portfolio_github_repos
      get  "connect",                to: "connect#show",           as: :connect
      post "connect/start",          to: "connect#start",          as: :connect_start
      get  "connect/refresh",        to: "connect#refresh",        as: :connect_refresh
      get  "complete",               to: "complete#show",          as: :complete
    end
    namespace :client do
    end
  end

  # Stripe webhooks
  namespace :webhooks do
    post "stripe/identity", to: "stripe#identity", as: :stripe_identity
  end

  # Agency / team (developer-scoped)
  namespace :developer do
    resource  :agency, only: [:show, :new, :create, :update], controller: "agency"
    resources :team_members, only: [:index, :new, :create, :destroy, :update],
              controller: "team_members"
  end

  # Admin
  namespace :admin do
    root "dashboard#index"

    resources :projects, only: [:index, :show]
    get "escrow", to: "escrow#index", as: :escrow

    resources :portfolio_submissions, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end

    resources :users, only: [:index, :show, :update] do
      member do
        post :revoke_identity
        post :verify_identity
        post :suspend
        post :unsuspend
        post :grant_admin
        post :revoke_admin
        post :impersonate
        post :stop_impersonating
      end
    end
  end

  mount ActionMailbox::Engine => "/rails/action_mailbox"
end