REPOSITORY_CACHE_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/repository_cache.yml")[Rails.env]
