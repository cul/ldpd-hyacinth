require "active-fedora"
require 'jettywrapper'
jetty_zip_basename = 'hyacinth-fedora-3.7-with-risearch'
Jettywrapper.url = "https://github.com/elo2112/hydra-jetty/archive/#{jetty_zip_basename}.zip"

def print_out_solr_and_fedora_urls
  puts '---------------------------'
  puts 'Fedora URL: ' + ActiveFedora.config.credentials[:url]
  puts 'Solr URL: ' + ActiveFedora.solr_config[:url]
  puts '---------------------------'
  puts ''
end

namespace :hyacinth do

  

end
