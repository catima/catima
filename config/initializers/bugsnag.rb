Bugsnag.configure do |config|
  config.api_key = (ENV["BUGSNAG_API_KEY"].presence)

  config.app_version = (ENV["APP_VERSION"].presence || 'undefined')

  config.release_stage = (ENV["RAILS_ENV"].presence)

  config.notify_release_stages = %w[staging production]
end
