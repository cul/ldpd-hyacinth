# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite do
  let(:datacite) do
    described_class.new(rest_api: 'https://api.test.datacite.org',
                        user: 'FriendlyUser',
                        password: 'FriendlyPassword',
                        prefix: '10.33555')
  end
  let(:dod) do
    data = JSON.parse(file_fixture('files/datacite/item.json').read)
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
    {
      "data":
       {
         "type":"dois",
         "attributes":
          {
            "prefix":"10.33555",
            "schemaVersion":"http://datacite.org/schema/kernel-4",
            "creators":[{"name":"Salinger, J. D."},{"name":"Lincoln, Abraham"}],
            "titles":[{"title":"The Catcher in the Rye"}],
            "publisher":"The Best Publisher Ever",
            "publicationYear":1951,
            "types":{"resourceTypeGeneral":"Image"},
            "url":"https://www.columbia.edu"
          }
       }
    }
    '
  end
  let(:no_metadata_payload_json) do
    '
    {
      "data":
       {
         "type":"dois",
         "attributes":
          {
            "prefix":"10.33555",
            "schemaVersion":"http://datacite.org/schema/kernel-4"
          }
       }
    }
    '
  end
  let(:update_target_url_payload_json) do
    '
    {
      "data":
       {
         "type":"dois",
         "attributes":
          {
            "prefix":"10.33555",
            "schemaVersion":"http://datacite.org/schema/kernel-4",
            "url":"https://www.columbia.edu"
          }
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

  let(:digital_object) do
    obj = DigitalObject::Item.new
    allow(obj).to receive(:as_json).and_return(dod)
    allow(obj).to receive(:title).and_return(dod['title'])
    allow(obj).to receive(:generate_display_label).and_call_original
    obj
  end

  describe '#exists?' do
    it "returns true for a DOI that is present in DataCite" do
      stub_request(:get, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers_no_content
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      expect(datacite.exists?('10.33555/tb9q-qb07')).to be_truthy
    end

    it "returns false for a DOI that is not present in DataCite" do
      stub_request(:get, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07abc").with(
        headers: mocked_headers_no_content
      ).to_return(status: 404, body: doi_not_found_response_body_json, headers: {})
      expect(datacite.exists?('10.33555/tb9q-qb07abc')).to be_falsey
    end
  end

  describe '#handles?' do
    it "returns true if the passed-in identifier is handle by DataCite" do
      expect(datacite.handles?('10.33555/tb9q-qb07')).to be_truthy
    end

    it "returns false if the passed-in identifier is not handled by DataCite" do
      expect(datacite.handles?('11.33555/tb9q-qb07abc')).to be_falsey
    end
  end

  describe '#as_datacite_properties' do
    let(:delegate) { Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata }
    let(:target_url) { 'https://www.columbia.edu' }
    it "delegates to HyacinthMetadata class method" do
      expect(delegate).to receive(:as_datacite_properties).with(digital_object, target_url)
      datacite.as_datacite_properties(digital_object, target_url)
    end
  end

  describe '#mint' do
    let(:target_url) { nil }
    let(:doi_state) { :draft }
    let(:minted_doi) { datacite.mint(digital_object: digital_object, target_url: target_url, doi_state: doi_state) }
    context "no DigitalObject supplied" do
      let(:digital_object) { nil }
      it "calls the appropriate Api method" do
        stub_request(:post, "https://api.test.datacite.org/dois").with(
          headers: mocked_headers,
          body: no_metadata_payload_json.gsub(/\n\s+/, '')
        ).to_return(status: 201, body: no_metadata_response_body_json, headers: {})
        expect(minted_doi).to eql("10.33555/tb9q-qb07")
      end
      context "and status is not draft" do
        let(:doi_state) { :findable }
        it "returns nil" do
          expect(minted_doi).to be_nil
        end
      end
    end

    context "metadata supplied (via DigitalObject instance)." do
      let(:target_url) { 'https://www.columbia.edu' }
      it "calls the appropriate Api method, " do
        stub_request(:post, "https://api.test.datacite.org/dois").with(
          headers: mocked_headers,
          body: metadata_payload_json.gsub(/\n\s+/, '')
        ).to_return(status: 201, body: no_metadata_response_body_json, headers: {})
        expect(minted_doi).to eql("10.33555/tb9q-qb07")
      end
    end
  end

  describe '#update' do
    it "calls the appropriate Api method" do
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers,
        body: metadata_payload_json.gsub(/\n\s+/, '')
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      datacite.update('10.33555/tb9q-qb07', digital_object: digital_object, location_uri: 'https://www.columbia.edu')
    end
  end

  describe '#update_location_uri' do
    it "calls the appropriate Api method" do
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/tb9q-qb07").with(
        headers: mocked_headers,
        body: update_target_url_payload_json.gsub(/\n\s+/, '')
      ).to_return(status: 200, body: no_metadata_response_body_json, headers: {})
      datacite.update_location_uri('10.33555/tb9q-qb07', 'https://www.columbia.edu')
    end
  end
end
