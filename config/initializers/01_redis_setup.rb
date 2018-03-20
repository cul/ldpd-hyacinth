require 'redis'
require 'redis-namespace'
REDIS_CONFIG = YAML.load_file(Rails.root.join('config', 'redis.yml'))[Rails.env].with_indifferent_access
Redis.current = Redis::Namespace.new(REDIS_CONFIG['namespace'], redis: Redis.new(REDIS_CONFIG))
