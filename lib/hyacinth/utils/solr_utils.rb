class Hyacinth::Utils::SolrUtils
  # TODO: Maybe change this to a solr connection pool (like in uri_service gem)
  def self.solr
    # If you need to change the read/open timeouts for solr: RSolr.connect({:read_timeout => 120, :open_timeout => 120})
    @solr ||= RSolr.connect(url: HYACINTH['solr_url'])
  end

  def self.solr_escape(str)
    UriService.solr_escape(str)
  end
end
