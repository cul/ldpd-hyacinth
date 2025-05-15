module Hyacinth::Datacite
  class ServerResponse
    attr_reader :response, :parsed_body_hash

    def initialize(response)
      @response = response
      @response_body_hash = JSON.parse response.body
      # fcd1, 12/16/21: @parsed_body_hash not used in code
    end

    def success?
      @response.body[0..6] == 'success'
    end

    def error?
      @response_body_hash.key? 'errors'
    end

    def error_status
      @response_body_hash['errors'].first['status']
    end

    def error_title
      @response_body_hash['errors'].first['title']
    end

    def doi
      datacite_doi = @response_body_hash.dig('data', 'attributes', 'doi')
      # fcd1, 12/19/21: Need to add 'doi:' to returned value in order to match
      # what is expected downstream. If 'doi:' prefix is not included,
      # DigitalObject::Persistence#persist_to_stores generates following error
      # when running 'bundle exec rake hyacinth:ci':
      # Invalid target "10.33555/2p7g-a905". Must have namespace.
      "doi:#{datacite_doi}"
    end

    def http_status_code
      @response.code
    end

    def http_server_message
      @response.msg
    end

    def body
      @response.body
    end

    def to_str
      @response.to_s
    end
  end
end
