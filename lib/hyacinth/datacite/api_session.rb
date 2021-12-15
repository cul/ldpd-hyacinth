# fcd1, 08/30/16: Original code was copied verbatim from
# hypatia-new, and then modified. Modifications should be
# kept to a minimum

# This code interfaces with the EZID server
# and therefore implements parts of the EZID server
# API (http://ezid.cdlib.org/doc/apidoc.2.html)
# EZID API, Version 2

require 'net/http'
require 'hyacinth/datacite/server_response'
require 'hyacinth/datacite/doi'

module Hyacinth::Datacite
  class ApiSession
    attr_accessor :naa, :username, :password
    attr_reader :scheme, :last_response_from_server, :timed_out
    # Events used when minting a DOI, depends on desired state of minted DOI
    # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
    DOI_MINT_EVENT = { 'draft' => '',
                       'findable' => 'publish',
                       'registered' => 'hide' }.freeze

    def initialize(username,
                   password)
      @username = username
      @password = password
      @last_response_from_server = nil
      @timed_out = false
    end

    def timed_out?
      timed_out
    end

    def mint_identifier(prefix,
                        doi_status,
                        target_url = nil,
                        attributes_hash = {},
                        identifier_type = :doi)
      # fcd1, 12/20/21: indentifier_type will always be :doi, if specified
      # return nil unless identifier_type == :doi
      attributes_hash[:url] = target_url unless target_url.nil?
      attributes_hash[:event] =  DOI_MINT_EVENT[doi_status] unless doi_status == :draft
      attributes_hash[:prefix] = prefix
      uri_path = '/dois'
      uri = URI(EZID[:url] + uri_path)
      request = Net::HTTP::Post.new uri.request_uri
      begin
        response = call_api(uri, request, attributes_hash)
        @last_response_from_server = Hyacinth::Datacite::ServerResponse.new response
        Hyacinth::Utils::Logger.logger.error("#mint_identifier: Response from DataCite server failed:\n" \
                                             "doi_status: #{doi_status}\n" \
                                             "target_url: #{target_url}\n" \
                                             "url suffix: #{uri}\n" \
                                             "datacite attributes: #{attributes_hash.inspect}\n" \
                                             "response body: #{response.body}") if @last_response_from_server.error?
        Hyacinth::Datacite::Doi.new(@last_response_from_server.doi,
                                    doi_status) unless @last_response_from_server.error?
      rescue Net::ReadTimeout, SocketError
        Hyacinth::Utils::Logger.logger.error('#mint_identifier: EZID API call to mint identifier timed-out')
        @timed_out = true
        nil
      end
    end

    def modify_identifier(doi,
                          doi_status,
                          attributes_hash,
                          target_url = nil)
      attributes_hash[:url] = target_url unless target_url.nil?
      attributes_hash[:event] = DOI_MINT_EVENT[doi_status] unless doi_status == :draft
      attributes_hash[:prefix] = EZID[:prefix]
      uri_path = '/dois/' + doi
      uri = URI(EZID[:url] + uri_path)
      request = Net::HTTP::Put.new uri.request_uri
      begin
        response = call_api(uri, request, attributes_hash)
        @last_response_from_server = Hyacinth::Datacite::ServerResponse.new response
        Hyacinth::Utils::Logger.logger.error("#modify_identifier: Response from DataCite server failed:\n" \
                                             "doi_status: #{doi_status}\n" \
                                             "target_url: #{target_url}\n" \
                                             "url suffix: #{uri}\n" \
                                             "datacite attributes: #{attributes_hash.inspect}\n" \
                                             "response body: #{response.body}") if @last_response_from_server.error?
        Hyacinth::Datacite::Doi.new(@last_response_from_server.doi,
                                doi_status) unless @last_response_from_server.error?
      rescue Net::ReadTimeout, SocketError
        Hyacinth::Utils::Logger.logger.error('modify_identifier: EZID API call to modify identifier timed-out')
        @timed_out = true
        false
      end
    end

    private

      def call_api(uri, request, attributes = nil)
        data = { type: 'dois' }
        data[:attributes] = attributes
        request.body = { data: data }.to_json
        # fcd1, 12/23/21: Following can be uncommented for in situ debugging
        # Hyacinth::Utils::Logger.logger.error("URL: #{uri}")
        # Hyacinth::Utils::Logger.logger.error("REQUEST BODY #{request.body}")
        request.basic_auth @username, @password
        request.add_field('Content-Type', 'application/vnd.api+json')
        result = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          response = http.request(request)
          response
        end
        # fcd1, 12/23/21: Following can be uncommented for in situ debugging
        # Hyacinth::Utils::Logger.logger.error("RESPONSE STATUS/CODE #{result.code}")
        # Hyacinth::Utils::Logger.logger.error("RESPONSE MSG #{result.msg}")
        # Hyacinth::Utils::Logger.logger.error("RESPONSE BODY #{result.body}")
        result
      end
  end
end
