HYACINTH = YAML.load_file("#{Rails.root.to_s}/config/hyacinth.yml")[Rails.env]

puts '---------------------------'
puts 'Initializing Hyacinth in environment: ' + Rails.env
puts '---------------------------'
puts 'Rails ENV: ' + Rails.env
puts 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
puts 'Hydra Solr URL: ' + ActiveFedora.solr_config[:url]
puts 'Hyacinth Solr URL: ' + HYACINTH['solr_url']
puts '---------------------------'
puts ''

raise 'Error: Please set a value for publish_target_api_key_encryption_key in your hyacinth.yml file' if HYACINTH['publish_target_api_key_encryption_key'].blank?

# For EXTREME debugging with full stack traces.  Woo!
Rails.backtrace_cleaner.remove_silencers! if Rails.env.development?

# Create upload_directory, default_asset_home directory and csv_export_directory if they don't exist
FileUtils.mkdir_p(HYACINTH['upload_directory']) if HYACINTH['upload_directory']
FileUtils.mkdir_p(HYACINTH['default_asset_home']) if HYACINTH['default_asset_home']
FileUtils.mkdir_p(HYACINTH['csv_export_directory']) if HYACINTH['csv_export_directory']

#
## Raise error if default pid generator is not specified
#raise 'Missing default pid generator.  Please set one in your hyacinth.yml file.' if HYACINTH['default_pid_generator_namespace'].nil?
#
## Raise error if we cannot connect to Fedora
#content_aggregator_cmodel = nil
#begin
#  content_aggregator_cmodel = ActiveFedora::Base.find('ldpd:ContentAggregator') # Attempt to retrieve
#rescue Errno::ECONNREFUSED => e
#  raise 'Error: Could not connect to fedora. (' + e.message + ')'
#end
#
## Raise error if required ContentModels haven't been loaded yet
#if content_aggregator_cmodel.nil?
#  begin
#    content_aggregator_cmodel = ActiveFedora::Base.find('ldpd:ContentAggregator') # Attempt to retrieve
#  rescue Errno::ECONNREFUSED => e
#    raise 'Error: Could not find ContentAggregator ContentModel.  Have you loaded all required ContentModel? (' + e.message + ')'
#  end
#end
