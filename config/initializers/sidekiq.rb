Sidekiq.configure_server do |config|
  config.redis = { :namespace => "viim_core" }
  # config.redis = { db: 1 }
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => "viim_core" }
  # config.redis = { url: "redis://localhost:6379/1" }
  # config.redis = { db: 1 }
end

require "sidekiq/web"
Sidekiq::Web.app_url = "/"
Sidekiq::Web.use(Rack::Auth::Basic, "Application") do |username, password|
  username == ENV.fetch("SIDEKIQ_WEB_USERNAME") &&
  password == ENV.fetch("SIDEKIQ_WEB_PASSWORD")
end
