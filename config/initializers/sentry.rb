Sentry.init do |config|
  config.dsn = 'https://a75631bc4622decc7f2d25ee960568ad@o4510653305454592.ingest.us.sentry.io/4511371677270016'
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
  config.enabled_environments = ['production', 'development', 'staging', 'test']
  config.background_worker_threads = 0
end

puts "Sentry initialized? #{!Sentry.get_current_client.nil?}"