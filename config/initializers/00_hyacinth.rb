HYACINTH = YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env]
EZID = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/ezid.yml")[Rails.env])

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

[
  'data_directory',
  'upload_directory',
  'default_asset_home',
  'csv_export_directory',
  'processed_csv_import_directory'
].each do |required_config_key|
  if HYACINTH[required_config_key].present?
    FileUtils.mkdir_p(HYACINTH[required_config_key])
  else
    raise "Missing required Hyacinth config key: #{required_config_key}"
  end
end
