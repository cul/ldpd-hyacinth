require 'redis'
require 'redis-namespace'
REDIS_CONFIG = Rails.application.config_for('redis')
Redis.current = Redis::Namespace.new(REDIS_CONFIG[:namespace], redis: Redis.new(REDIS_CONFIG))
