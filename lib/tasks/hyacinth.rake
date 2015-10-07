require "active-fedora"
require 'jettywrapper'
#Jettywrapper.url = "https://github.com/cul/hydra-jetty/archive/hyacinth-fedora-3.8.1-with-risearch.zip"
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/7.x-stable.zip"

def print_out_solr_and_fedora_urls
  puts '---------------------------'
  puts 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
  puts 'Solr URL: ' + ActiveFedora.solr_config[:url]
  puts '---------------------------'
  puts ''
end

namespace :hyacinth do

end
