class Hyacinth::Utils::SolrUtils

  def self.solr
    # If you need to change the read/open timeouts for solr: RSolr.connect({:read_timeout => 120, :open_timeout => 120})
    @solr ||=  RSolr.connect(:url => HYACINTH['solr_url'])
  end

end
