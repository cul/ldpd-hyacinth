require "active-fedora"

def print_out_solr_and_fedora_urls
  puts '---------------------------'
  puts 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
  puts 'Solr URL: ' + ActiveFedora.solr_config[:url]
  puts '---------------------------'
  puts ''
end

namespace :hyacinth do

end
