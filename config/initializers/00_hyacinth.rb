HYACINTH = Rails.application.config_for(:hyacinth).tap do |config|
  config[:publish_enabled] = true if config[:publish_enabled].nil?
end

class HyacinthConfigValidator
  def self.validate!(config)
    errors = []

    # Validate top level keys
    %i[
      solr_url
      default_pid_generator_namespace
      digital_object_data_directory
      default_resource_storage_locations
      upload_directory
      csv_export_directory
      processed_csv_import_directory
      publish_target_api_key_encryption_key
      treat_fedora_resource_index_updates_as_immediate
      queue_long_jobs
      time_zone
      solr_commit_after_each_csv_import_row
    ].each do |required_config_key|
      errors << "Missing #{required_config_key.inspect}" if HYACINTH[required_config_key].nil?
    end

    # Validate storage location file permissions if set
    HYACINTH[:default_resource_storage_locations].each do |resource_name, opts|
      if opts.dig(:file, :permissions).present?
        mode = opts.dig(:file, :permissions)
        unless mode.is_a?(String) && mode =~ /^0[0-7]{3}$/
          errors << "Invalid value supplied for HYACINTH[:#{resource_name}][:file][:permissions]. "\
            "Must be a String like '0777' or '0640'."
        end
      end
    end

    raise "Your hyacinth.yml config file is not valid due to the following errors:\n- #{errors.join("\n- ")}" if errors.present?
  end
end

HyacinthConfigValidator.validate!(HYACINTH)

# Create config-defined directories if they do not exist
%i[
  digital_object_data_directory
  upload_directory
  csv_export_directory
  processed_csv_import_directory
].each do |directory_name|
  FileUtils.mkdir_p(HYACINTH[directory_name.to_sym])
end

Rails.application.config.active_job.queue_adapter = :inline unless HYACINTH[:queue_long_jobs]

DATACITE = HashWithIndifferentAccess.new(Rails.application.config_for(:datacite))
IMAGE_SERVER_CONFIG = Rails.application.config_for(:image_server)
DERIVATIVE_SERVER_CONFIG = Rails.application.config_for(:derivative_server)

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
