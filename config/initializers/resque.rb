Resque.redis = Redis.current
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
Resque.logger.level = Rails.logger.level

RESQUE_CONFIG = Rails.application.config_for('resque')
