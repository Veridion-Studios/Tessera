WebAuthn.configure do |config|
  config.origin         = ENV.fetch("APP_HOST", "http://localhost:5000")
  config.rp_name        = "Tessera"
  config.rp_id          = URI.parse(ENV.fetch("APP_HOST", "http://localhost:5000")).host
end