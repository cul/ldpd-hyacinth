rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
RESQUE_CONFIG = ActiveSupport::HashWithIndifferentAccess.new(YAML.load_file(rails_root + '/config/resque.yml')[rails_env])

Resque.redis = RESQUE_CONFIG['url']
Resque.redis.namespace = 'resque:' + RESQUE_CONFIG['namespace']

Resque.logger = MonoLogger.new(File.open("#{Rails.root}/log/resque.log", "w+"))
Resque.logger.formatter = Resque::VerboseFormatter.new
