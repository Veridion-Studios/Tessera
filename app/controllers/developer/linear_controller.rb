module Developer
  class LinearController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!
    REDIRECT_URI = "#{ENV['APP_HOST']}/dashboard/developer/linear/callback".freeze

    def connect
      # Linear OAuth — redirect to Linear's auth page
      params = {
        client_id:     ENV["LINEAR_CLIENT_ID"],
        redirect_uri:  REDIRECT_URI,
        response_type: "code",
        scope:         "read write",
        state:         session[:linear_state] = SecureRandom.hex(16)
      }
      redirect_to "https://linear.app/oauth/authorize?#{params.to_query}", allow_other_host: true
    end

    def callback
      if params[:state] != session[:linear_state]
        redirect_to developer_portfolio_path, alert: "Invalid OAuth state." and return
      end

      response = Faraday.post("https://api.linear.app/oauth/token") do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = {
          code:          params[:code],
          redirect_uri:  REDIRECT_URI,
          client_id:     ENV["LINEAR_CLIENT_ID"],
          client_secret: ENV["LINEAR_CLIENT_SECRET"],
          grant_type:    "authorization_code"
        }
      end

      data = JSON.parse(response.body)

      unless data["access_token"]
        redirect_to developer_portfolio_path, alert: "Linear OAuth failed." and return
      end

      # Fetch workspace info
      gql_response = Faraday.post("https://api.linear.app/graphql") do |req|
        req.headers["Authorization"] = "Bearer #{data['access_token']}"
        req.headers["Content-Type"]  = "application/json"
        req.body = { query: "{ viewer { organization { name } } teams { nodes { id name } } }" }.to_json
      end
      gql = JSON.parse(gql_response.body)
      org   = gql.dig("data", "viewer", "organization", "name")
      teams = gql.dig("data", "teams", "nodes") || []
      team  = teams.first

      current_user.developer_profile.update!(
        linear_access_token:   data["access_token"],
        linear_workspace_name: org,
        linear_team_id:        team&.dig("id"),
        linear_team_name:      team&.dig("name")
      )

      redirect_to developer_portfolio_path, notice: "Linear connected — #{org}."
    end

    def disconnect
      current_user.developer_profile.update!(
        linear_access_token:   nil,
        linear_workspace_name: nil,
        linear_team_id:        nil,
        linear_team_name:      nil
      )
      redirect_to developer_portfolio_path, notice: "Linear disconnected."
    end

    def issues
      profile = current_user.developer_profile
      unless profile.linear_access_token.present?
        render json: { error: "Not connected" }, status: :unprocessable_entity and return
      end

      q = params[:q].to_s.strip
      filter = q.present? ? ", filter: { title: { containsIgnoreCase: \"#{q}\" } }" : ""
      team_filter = profile.linear_team_id.present? ? "teamId: \"#{profile.linear_team_id}\"" : ""

      gql = <<~GQL
        {
          issues(first: 20#{filter}) {
            nodes { id title url identifier state { name color } }
          }
        }
      GQL

      response = Faraday.post("https://api.linear.app/graphql") do |req|
        req.headers["Authorization"] = "Bearer #{profile.linear_access_token}"
        req.headers["Content-Type"]  = "application/json"
        req.body = { query: gql }.to_json
      end

      data = JSON.parse(response.body)
      issues = data.dig("data", "issues", "nodes") || []
      render json: issues
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end
  end
end