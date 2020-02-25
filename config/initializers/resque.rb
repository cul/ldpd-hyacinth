# frozen_string_literal: true

# Set resque to log to a file
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
Resque.logger.level = Logger::DEBUG

redis_config = Rails.application.config_for(:redis)
resque_config = Rails.application.config_for(:resque)

# Apply redis config to resque
Resque.redis = redis_config
# Set the namespace
Resque.redis.namespace = 'Resque:' + redis_config[:namespace]

# Resque jobs should run inline in the test environment rather than being queued
Resque.inline = resque_config[:inline]
