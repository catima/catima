Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_API_KEY"].present? ? ENV["BUGSNAG_API_KEY"] : nil

  config.app_version = ENV["APP_VERSION"].present? ? ENV["APP_VERSION"] : 'undefined'

  config.release_stage = ENV["RAILS_ENV"].present? ? ENV["RAILS_ENV"] : nil

  config.notify_release_stages = %w[staging production]
end
