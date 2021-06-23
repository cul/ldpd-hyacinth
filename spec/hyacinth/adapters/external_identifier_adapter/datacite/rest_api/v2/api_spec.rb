# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api do
  let(:api) { described_class.new('https://api.test.datacite.org', 'FriendlyUser', 'FriendlyPassword') }
  let(:json_payload_update_doi) do
    '
    {"data":
       {"type":"dois",
        "attributes":
          {"titles":
             [{"title":"The Good Title"}],
           "creators":
             [{"name":"Doe, Jane"}],
           "url":"https://www.columbia.edu",
           "publisher":"Self",
           "publicationYear":2002,
           "types":
             {"resourceTypeGeneral":"Text"},
           "schemaVersion":"http://datacite.org/schema/kernel-4",
           "prefix":"10.33555"}
       }
    }
    '
  end

  let(:metadata) do
    { type: 'dois',
      attributes: {
        doi: '10.33555/0645-3z82',
        state: 'draft',
        titles: [{ title: 'The Good Title' }],
        creators: [{ name: "Doe, Jane" }],
        url: 'https://www.columbia.edu',
        publisher: 'Self',
        publicationYear: 2002,
        types: { resourceTypeGeneral: 'Text' },
        schemaVersion: 'http://datacite.org/schema/kernel-4',
        prefix: '10.33555'
      } }
  end
  let(:mocked_headers_with_content) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/vnd.api+json', 'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:mocked_headers_no_content) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:api_response_body) do
    { data: metadata }
  end

  describe '#parse_doi_from_api_response_body' do
    it "parses the doi from the body of the API http response" do
      expect(api.parse_doi_from_api_response_body(JSON.generate(api_response_body))).to eq('10.33555/0645-3z82')
    end
  end

  describe '#parse_state_from_api_response_body' do
    it "parses the state from the body of the API http response" do
      expect(api.parse_state_from_api_response_body(JSON.generate(api_response_body))).to eq('draft')
    end
  end

  describe '#parse_url_from_api_response_body' do
    it "parses the target url from the body of the API http response" do
      expect(api.parse_url_from_api_response_body(JSON.generate(api_response_body))).to eq('https://www.columbia.edu')
    end
  end

  describe '#get_dois' do
    it "sends a GET request" do
      stub_request(:get, "https://api.test.datacite.org/dois/10.33555/2Y0J-BC24").with(
        headers: mocked_headers_no_content
      ).to_return(status: 200, body: JSON.generate(api_response_body), headers: {})
      api.get_dois('10.33555/2Y0J-BC24')
    end
  end

  describe '#post_dois' do
    it "sends a POST request" do
      data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new
      stub_request(:post, "https://api.test.datacite.org/dois").with(
        headers: mocked_headers_with_content
      ).to_return(status: 201, body: JSON.generate(api_response_body), headers: {})
      api.post_dois(data.generate_json_payload)
    end
  end

  describe '#put_dois' do
    it "sends a PUT request" do
      data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new
      data.data_hash = metadata
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/2Y0J-BC24").with(
        body: json_payload_update_doi,
        headers: mocked_headers_with_content
      ).to_return(status: 200, body: "", headers: {})
      api.put_dois('10.33555/2Y0J-BC24', json_payload_update_doi)
    end
  end
end
