HYACINTH = YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env]

Hyacinth::Utils::Logger.logger.tap do |logger|
  logger.info '---------------------------'
  logger.info 'Initializing Hyacinth in environment: ' + Rails.env
  logger.info '---------------------------'
  logger.info 'Rails ENV: ' + Rails.env
  logger.info 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
  logger.info 'Hydra Solr URL: ' + ActiveFedora.solr_config[:url]
  logger.info 'Hyacinth Solr URL: ' + HYACINTH['solr_url']
  logger.info '---------------------------'
  logger.info ''
end

raise 'Error: Please set a value for publish_target_api_key_encryption_key in your hyacinth.yml file' if HYACINTH['publish_target_api_key_encryption_key'].blank?

# For EXTREME debugging with full stack traces.  Woo!
Rails.backtrace_cleaner.remove_silencers! if Rails.env.development?

# Create upload_directory, default_asset_home directory and csv_export_directory if they don't exist
FileUtils.mkdir_p(HYACINTH['upload_directory']) if HYACINTH['upload_directory']
FileUtils.mkdir_p(HYACINTH['default_asset_home']) if HYACINTH['default_asset_home']
FileUtils.mkdir_p(HYACINTH['csv_export_directory']) if HYACINTH['csv_export_directory']
FileUtils.mkdir_p(HYACINTH['processed_csv_import_directory']) if HYACINTH['processed_csv_import_directory']
