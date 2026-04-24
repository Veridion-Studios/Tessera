Rails.application.config.middleware.use OmniAuth::Builder do
  github_options = {
    scope: "read:user,public_repo"
  }

  if ENV["SSL_CERT_FILE"].present?
    github_options[:client_options] = {
      ssl: { ca_file: ENV["SSL_CERT_FILE"] }
    }
  end

  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], **github_options
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true