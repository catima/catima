Bugsnag.configure do |config|
  config.api_key = ENV.fetch("BUGSNAG_API_KEY", nil)

  config.app_version = ENV["APP_VERSION"] ? "v".concat(ENV["APP_VERSION"]) : 'undefined'

  config.release_stage = ENV.fetch("RAILS_ENV", nil)

  config.notify_release_stages = %w[staging production]
end
