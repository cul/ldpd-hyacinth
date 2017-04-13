rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
RESQUE_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load_file(rails_root + '/config/resque.yml')[rails_env])

if HYACINTH['queue_long_jobs']
  Resque.redis = RESQUE_CONFIG['url']
  Resque.redis.namespace = 'resque:' + RESQUE_CONFIG['namespace']
  
  Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
  Resque.logger.level = Rails.logger.level
end