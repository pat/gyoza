Bugsnag.configure do |config|
  config.api_key               = ENV.fetch("BUGSNAG_API_KEY", "EMPTY")
  config.notify_release_stages = %w( production staging )
  config.release_stage         = Rails.env
end
