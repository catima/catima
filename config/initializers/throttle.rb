require "redis"

REDIS = Redis.new(
  :host => ENV.fetch('REDIS_HOST', 'localhost'),
  :port => ENV.fetch('REDIS_PORT', '6379'),
  :db => ENV.fetch('REDIS_DB', '0')
)
