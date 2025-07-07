HYACINTH = Rails.application.config_for(:hyacinth).tap do |config|
  config[:publish_enabled] = true if config[:publish_enabled].nil?
end

EZID = HashWithIndifferentAccess.new(Rails.application.config_for(:ezid))

IMAGE_SERVER_CONFIG = Rails.application.config_for(:image_server)
DERIVATIVE_SERVER_CONFIG = Rails.application.config_for(:derivative_server)

raise 'Error: Please set a value for publish_target_api_key_encryption_key in your hyacinth.yml file' if HYACINTH[:publish_target_api_key_encryption_key].blank?

# For EXTREME debugging with full stack traces.  Woo!
# Rails.backtrace_cleaner.remove_silencers! if Rails.env.development?

# TODO: Update config validations below to account for new config options

# default_asset_home
# default_asset_home_bucket_name
# default_asset_home_bucket_path_prefix
# default_service_copy_home
# access_copy_directory
%i(
  digital_object_data_directory
  upload_directory
  csv_export_directory
  processed_csv_import_directory
).each do |required_config_key|
  if HYACINTH[required_config_key].present?
    FileUtils.mkdir_p(HYACINTH[required_config_key.to_sym])
  else
    raise "Missing required Hyacinth config key: #{required_config_key}"
  end
end

Rails.application.config.active_job.queue_adapter = :inline unless HYACINTH[:queue_long_jobs]

# Validate access_copy_file_permissions if set
if HYACINTH[:access_copy_file_permissions].present?
  mode = HYACINTH[:access_copy_file_permissions]
  unless mode.is_a?(String) && mode =~ /^0[0-7]{3}$/
    raise "Invalid value supplied for HYACINTH[:access_copy_file_permissions] configuration.  "\
      "Must be a String like '0777' or '0640'."
  end
end

Rails.application.config.after_initialize do
  # We need to run this after_initialize because at least one of our validations depends on
  # a constant from an auto-loaded file, and modules are only auto-loaded after initialization.

  Hyacinth::Utils::Logger.logger.tap do |logger|
    logger.info '---------------------------'
    logger.info 'Initializing Hyacinth in environment: ' + Rails.env
    logger.info '---------------------------'
    logger.info 'Rails ENV: ' + Rails.env
    logger.info 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
    logger.info 'Hydra Solr URL: ' + ActiveFedora.solr_config[:url]
    logger.info 'Hyacinth Solr URL: ' + HYACINTH[:solr_url]
    logger.info '---------------------------'
    logger.info ''
  end
end
