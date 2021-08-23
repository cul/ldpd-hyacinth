# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api
  MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI = [:title,
                                                  :creators,
                                                  :doi_url,
                                                  :publisher,
                                                  :publication_year,
                                                  :resource_type,
                                                  :doi_prefix].freeze
  # Events used when minting a DOI, depends on desired state of minted DOI
  # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
  DOI_STATES = [:draft, :findable, :registered].freeze
  DOI_MINT_EVENT = { draft: '',
                     findable: 'publish',
                     registered: 'hide' }.freeze

  include Hyacinth::Adapters::ConfigurableLogger

  attr_accessor :most_recent_request_body,
                :most_recent_response

  def initialize(datacite_rest_api_url = DATACITE[:rest_api],
                 basic_auth_user = DATACITE[:user],
                 basic_auth_password = DATACITE[:password])
    @datacite_rest_api_url = datacite_rest_api_url
    @basic_auth_user = basic_auth_user
    @basic_auth_password = basic_auth_password
    @logger = configured_logger(DATACITE)
  end

  # see https://support.datacite.org/reference/dois-2#get_dois-id
  # 'Returns a doi.'
  def get_dois(doi)
    conn = Faraday.new(@datacite_rest_api_url)
    conn.basic_auth(@basic_auth_user, @basic_auth_password)
    response = conn.get("/dois/#{doi}")
    logger.debug("API response body: #{response.body}")
    response
  end

  def parse_doi_from_api_response_body(api_http_response_body)
    JSON.parse(api_http_response_body).dig('data', 'attributes', 'doi')
  end

  def parse_state_from_api_response_body(api_http_response_body)
    JSON.parse(api_http_response_body).dig('data', 'attributes', 'state')
  end

  def parse_url_from_api_response_body(api_http_response_body)
    JSON.parse(api_http_response_body).dig('data', 'attributes', 'url')
  end

  # see https://support.datacite.org/reference/dois-2#post_dois
  # 'Add a new doi.'
  # In other words, used to mint DOIs
  def post_dois(request_body_json)
    conn = Faraday.new(@datacite_rest_api_url)
    conn.basic_auth(@basic_auth_user, @basic_auth_password)
    response = conn.post("/dois") do |req|
      req.headers['Content-Type'] = 'application/vnd.api+json'
      req.body = request_body_json
    end
    logger.debug("API response body: #{response.body}")
    response
  end

  # see https://support.datacite.org/reference/dois-2#put_dois-id
  # 'Update a doi.'
  def put_dois(doi, request_body_json)
    conn = Faraday.new(@datacite_rest_api_url)
    conn.basic_auth(@basic_auth_user, @basic_auth_password)
    response = conn.put("/dois/#{doi}") do |req|
      req.headers['Content-Type'] = 'application/vnd.api+json'
      req.body = request_body_json
    end
    logger.debug("API response body: #{response.body}")
    response
  end
end
