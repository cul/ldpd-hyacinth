# frozen_string_literal: true

# ba2213, 05/17/2019: Ported from Hyacinth 2 codebase
# fcd1, 08/30/16: Original code was copied verbatim from
# hypatia-new, and then modified. Modifications should be
# kept to a minimum

# This code interfaces with the EZID API at Datacite
# and therefore implements parts of the EZID server
# API (http://ezid.cdlib.org/doc/apidoc.2.html)
# EZID API, Version 2

require 'net/http'
require 'hyacinth/adapters/external_identifier_adapter/datacite/ezid_response'
require 'hyacinth/adapters/external_identifier_adapter/datacite/doi'

class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidSession
  include Hyacinth::Adapters::ConfigurableLogger

  attr_accessor :naa, :username, :password, :logger
  attr_reader :scheme, :last_response_from_server, :timed_out

  def initialize(username,
                 password)
    @username = username
    @password = password
    @last_response_from_server = nil
    @timed_out = false
    @logger = configured_logger(DATACITE)
  end

  def timed_out?
    timed_out
  end

  def get_identifier_metadata(identifier)
    request_uri = '/id/' + identifier
    uri = URI(DATACITE[:url] + request_uri)
    request = Net::HTTP::Get.new uri.request_uri
    begin
      response = call_api(uri, request)
      @last_response_from_server = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidResponse.new response
      @last_response_from_server.parsed_body_hash
    rescue Net::ReadTimeout, SocketError
      logger.error('#get_identifier_metadata: EZID API call to get identifier metadata timed-out')
      @timed_out = true
      nil
    end
  end

  def mint_identifier(shoulder,
                      identifier_status,
                      target_url = nil,
                      metadata = {},
                      identifier_type = :doi)
    # we only handle doi identifiers.
    return nil unless identifier_type == :doi
    @identifier_type = identifier_type
    @shoulder = shoulder
    metadata['_target'] = target_url unless target_url.nil?
    metadata['_status'] = identifier_status
    request_uri = "/shoulder/#{@shoulder}"
    uri = URI(DATACITE[:url] + request_uri)
    request = Net::HTTP::Post.new uri.request_uri
    begin
      response = call_api(uri, request, metadata)
      @last_response_from_server = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidResponse.new response
      # following code chunk assumes we asked to mint a DOI identifier. Code will need to be changed
      # if ARK or URN identifiers support is added
      unless @last_response_from_server.success?
        logger.error("#mint_identifier: Response from EZID server failed:\n" \
                    "identifier_status: #{identifier_status}\n" \
                    "identifier_type: #{identifier_type}\n" \
                    "target_url: #{target_url}\n" \
                    "url suffix (includes shoulder): #{request_uri}\n" \
                    "datacite metadata: #{metadata.inspect}")
      end

      Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Doi.new(@last_response_from_server.doi, identifier_status) if @last_response_from_server.success?
    rescue Net::ReadTimeout, SocketError
      logger.error('#mint_identifier: EZID API call to mint identifier timed-out')
      @timed_out = true
      nil
    end
  end

  # metadata_hash will contain the metadata, including the EZID internal metadata
  # The datacite metadata (in XML format) will stored as value under the key 'datacite'
  # For the EZID internal data, the key is the name of the element as given in the EZID API.
  # For example, the key used for the identifier status is the element name '_status'
  # Method returns true if the API call was successful (HTTP status code set to 200
  # in the response from the EZID server).
  def modify_identifier(identifier, metadata_hash)
    request_uri = '/id/' + identifier
    uri = URI(DATACITE[:url] + request_uri)
    request = Net::HTTP::Post.new uri.request_uri
    begin
      response = call_api(uri, request, metadata_hash)
      @last_response_from_server = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidResponse.new response
      if @last_response_from_server.http_status_code == '200'
        true
      else
        false
      end
    rescue Net::ReadTimeout, SocketError
      logger.error('modify_identifier: EZID API call to modify identifier timed-out')
      @timed_out = true
      false
    end
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
      escape = ->(s) { URI.escape(s, /[%:\n\r]/) }
      anvl = ''
      metadata.each do |n, v|
        # fcd1, 08/31/16: code changes due to lambda instead of nested method defintion
        # anvl += escape(n.to_s) + ': ' + escape(v.to_s) + "\n"
        anvl += escape.call(n.to_s) + ': ' + escape.call(v.to_s) + "\n"
      end
      anvl.strip
    end
end
