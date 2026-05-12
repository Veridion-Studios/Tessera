Sentry.init do |config|
  # Read DSN from environment. Set `SENTRY_DSN` in your environment or .env file.
  # Example: SENTRY_DSN="https://public_key@o0.ingest.sentry.io/0"
  config.dsn = ENV['SENTRY_DSN']
  # get breadcrumbs from logs
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # Add data like request headers and IP for users, if applicable;
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
  # enable tracing
  # we recommend adjusting this value in production
  config.traces_sample_rate = 1.0
  # enable event sampling - ensure events are sent in all environments
  config.sample_rate = 1.0
  # don't filter events by environment
  config.enabled_environments = ['production', 'staging', 'test']
  config.background_worker_threads = 0
end

puts "Sentry initialized? #{!Sentry.get_current_client.nil?}"