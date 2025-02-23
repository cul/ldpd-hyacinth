# frozen_string_literal: true

# Set resque to log to a file
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
# Match the Rails logger level
Resque.logger.level = Rails.logger.level

redis_config = Rails.application.config_for(:redis)

# Apply redis config to resque
Resque.redis = redis_config
# Set the namespace
Resque.redis.namespace = "Resque:#{redis_config[:namespace]}"
