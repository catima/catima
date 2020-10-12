Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_API_KEY"]

  config.notify_release_stages = ['production']

  config.release_stage = ENV['CLUE_OVERRIDE'] || ENV["RAILS_ENV"]
end
