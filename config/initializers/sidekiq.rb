Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST'].presence || 'localhost'}:#{ENV['REDIS_PORT'].presence || '6379'}/#{ENV['REDIS_DB'].presence || '0'}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV['REDIS_HOST'].presence || 'localhost'}:#{ENV['REDIS_PORT'].presence || '6379'}/#{ENV['REDIS_DB'].presence || '0'}"
  }
end
