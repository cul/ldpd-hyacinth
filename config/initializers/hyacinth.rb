puts '---------------------------'
puts 'Initializing Hyacinth in environment: ' + Rails.env
puts '---------------------------'
puts 'Rails ENV: ' + Rails.env
puts 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
puts 'Solr URL: ' + ActiveFedora.solr_config[:url]
puts '---------------------------'
puts ''

HYACINTH = YAML.load_file("#{Rails.root.to_s}/config/hyacinth.yml")[Rails.env]
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
