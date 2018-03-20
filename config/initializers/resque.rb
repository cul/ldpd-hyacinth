Resque.redis = Redis.current
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
Resque.logger.level = Rails.logger.level

RESQUE_CONFIG = YAML.load_file(Rails.root.join('config', 'resque.yml'))[Rails.env].with_indifferent_access
