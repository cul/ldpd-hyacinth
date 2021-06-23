# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite do
  let(:datacite) { described_class.new }
  let(:dod) do
    data = JSON.parse(file_fixture('files/datacite/ezid_item.json').read)
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
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
  let(:metadata_payload_json) do
    '
    {"data":
       {"type":"dois",
        "attributes":
          {"prefix":"10.33555",
           "creators":
             [{"name":"Salinger, J. D."},{"name":"Lincoln, Abraham"}],
           "titles":
             [{"title":"The Catcher in the Rye"}],
           "publisher":"The Best Publisher Ever",
           "publicationYear":1951,
           "types":
             {"resourceTypeGeneral":"Image"},
           "url":"https://www.columbia.edu",
           "schemaVersion":"http://datacite.org/schema/kernel-4"}
       }
    }
    '
  end
  let(:mocked_headers) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/vnd.api+json', 'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:mocked_headers_no_content) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:no_metadata_response_body_json) do
    '{"data":
       {"id":"10.33555/tb9q-qb07",
        "type":"dois",
        "attributes":
          {"doi":"10.33555/tb9q-qb07"}
       }
    }'
  end
  let(:doi_not_found_response_body_json) do
    "{\"errors\":
       [{\"status\":\"404\",\"title\":\"The resource you are looking for does'nt exist.\"}]
    }"
  end

  before do
    DATACITE[:rest_api] = 'https://api.test.datacite.org'
    DATACITE[:user] = 'FriendlyUser'
    DATACITE[:password] = 'FriendlyPassword'
    DATACITE[:prefix] = '10.33555'
  end

  describe '#exists?' do
    it " returns true for a DOI that is present in DataCite" do
      stub_request(:get, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers_no_content
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      expect(datacite.exists?('10.33555/tb9q-qb07')).to be_truthy
    end

    it " returns false for a DOI that is not present in DataCite" do
      stub_request(:get, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07abc").with(
        headers: mocked_headers_no_content
      ).to_return(status: 404, body: doi_not_found_response_body_json, headers: {})
      expect(datacite.exists?('10.33555/tb9q-qb07abc')).to be_falsey
    end
  end

  describe '#mint' do
    it " no metadata supplied. Calls the appropriate Api method" do
      stub_request(:post, "https://api.test.datacite.org/dois").with(
        headers: mocked_headers,
        body: '{"data":{"type":"dois","attributes":{"prefix":"10.33555"}}}'
      ).to_return(status: 201, body: no_metadata_response_body_json, headers: {})
      datacite.mint
    end

    it " metadata supplied (via Datacite::Metadata instance). Calls the appropriate Api method, " do
      metadata = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata.new dod
      stub_request(:post, "https://api.test.datacite.org/dois").with(
        headers: mocked_headers,
        body: metadata_payload_json.gsub(/\n\s+/, '')
      ).to_return(status: 201, body: no_metadata_response_body_json, headers: {})
      datacite.mint(metadata, 'https://www.columbia.edu')
    end
  end

  describe '#update_doi' do
    it " calls the appropriate Api method" do
      metadata = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata.new dod
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers,
        body: metadata_payload_json.gsub(/\n\s+/, '')
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      datacite.update_doi('10.33555/tb9q-qb07', metadata, 'https://www.columbia.edu')
    end
  end

  describe '#update_doi_target_url' do
    it " calls the appropriate Api method" do
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers,
        body: '{"data":{"type":"dois","attributes":{"prefix":"10.33555","url":"https://www.columbia.edu","schemaVersion":"http://datacite.org/schema/kernel-4"}}}'
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      datacite.update_doi_target_url('10.33555/tb9q-qb07', 'https://www.columbia.edu')
    end
  end
end
