# fcd1, 08/30/16: Original code was copied verbatim from
# hypatia-new, and then modified. Modifications should be
# kept to a minimum

# This code interfaces with the EZID server
# and therefore implements parts of the EZID server
# API (http://ezid.cdlib.org/doc/apidoc.2.html)
# EZID API, Version 2

require 'net/http'
require 'hyacinth/ezid/server_response'
require 'hyacinth/ezid/doi'

module Hyacinth::Ezid
  class ApiSession
    attr_accessor :naa, :username, :password
    attr_reader :scheme, :last_response_from_server

    SCHEMES = { ark: 'ark:/', doi: 'doi:' }

    IDENTIFIER_STATUS = { public: 'public',
                          reserved: 'reserved',
                          unavailable: 'unavailable' }

    def initialize(username = EZID[:test_user],
                   password = EZID[:test_password])
      @username = username
      @password = password
      @last_response_from_server = nil
    end

    def get_identifier_metadata(identifier)
      request_uri = '/id/' + identifier
      uri = URI(EZID[:url] + request_uri)
      request = Net::HTTP::Get.new uri.request_uri
      response = call_api(uri, request)
      @last_response_from_server = Hyacinth::Ezid::ServerResponse.new response
      @last_response_from_server.parsed_body_hash
    end

    def mint_identifier(identifier_type = :doi,
                        identifier_status = Hyacinth::Ezid::Doi::IDENTIFIER_STATUS[:reserved],
                        shoulder = EZID[:test_shoulder][:doi],
                        metadata = {})
      # we only handle doi identifiers.
      return nil unless identifier_type == :doi
      @identifier_type = identifier_type
      @shoulder = shoulder
      metadata['_status'] = identifier_status
      request_uri = "/shoulder/#{@shoulder}"
      uri = URI(EZID[:url] + request_uri)
      request = Net::HTTP::Post.new uri.request_uri
      response = call_api(uri, request, metadata)
      @last_response_from_server = Hyacinth::Ezid::ServerResponse.new response
      # following code chunk assumes we asked to mint a DOI identifier. Code will need to be changed
      # if ARK or URN identifiers support is added
      # BEGIN_CHUNK
      Hyacinth::Ezid::Doi.new(@last_response_from_server.doi,
                              @last_response_from_server.ark,
                              identifier_status) if @last_response_from_server.success?
      # END_CHUNK
    end

    # metada_hash will contain the metadata, including the EZID internal metadata
    # The datacite metadata (in XML format) will stored as value under the key 'datacite'
    # For the EZID internal data, the key is the name of the element as given in the EZID API.
    # For example, the key used for the identifier status is the element name '_status'
    def modify_identifier(identifier, metadata_hash)
      request_uri = '/id/' + identifier
      uri = URI(EZID[:url] + request_uri)
      request = Net::HTTP::Post.new uri.request_uri
      response = call_api(uri, request, metadata_hash)
      # response = call_api(request_uri, :post, metadata_hash)
      response
    end

    private

      def call_api(uri, request, request_data = nil)
        request.body = make_anvl(request_data) unless request_data.nil?

        request.basic_auth @username, @password
        request.add_field('Content-Type', 'text/plain; charset=UTF-8')

        result = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          response = http.request(request)
          response
        end
        result
      end

      def make_anvl(metadata)
        # fcd1, 08/31/16: Rubocop prefers a lambda instead of nested method definition
        # def escape(s)
        #   URI.escape(s, /[%:\n\r]/)
        #  end
        escape = -> (s) { URI.escape(s, /[%:\n\r]/) }
        anvl = ''
        metadata.each do |n, v|
          # fcd1, 08/31/16: code changes due to lambda instead of nested method defintion
          # anvl += escape(n.to_s) + ': ' + escape(v.to_s) + "\n"
          anvl += escape.call(n.to_s) + ': ' + escape.call(v.to_s) + "\n"
        end
        anvl.strip
      end
  end
end
