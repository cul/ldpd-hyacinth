# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite do
  let(:datacite) do
    described_class.new(rest_api: 'https://api.test.datacite.org',
                        user: 'FriendlyUser',
                        password: 'FriendlyPassword',
                        prefix: '10.33555')
  end
  let(:rest_api) { datacite.rest_api }
  let(:dod) do
    data = JSON.parse(file_fixture('files/datacite/item.json').read)
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
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
    obj.assign_attributes(dod)
    obj
  end

  let(:rest_api_response) { object_double(Faraday::Response.new, body: rest_api_response_body, status: rest_api_response_status) }
  describe '#exists?' do
    let(:doi) { '10.33555/tb9q-qb07' }
    before do
      expect(rest_api).to receive(:get_dois).with(doi).and_return(rest_api_response)
    end
    context "DOI is present in DataCite" do
      let(:rest_api_response_body) { no_metadata_response_body_json }
      let(:rest_api_response_status) { 200 }
      it "returns true" do
        expect(datacite.exists?(doi)).to be_truthy
      end
    end
    context "DOI is not present in DataCite" do
      let(:rest_api_response_body) { doi_not_found_response_body_json }
      let(:rest_api_response_status) { 404 }
      it "returns false" do
        expect(datacite.exists?(doi)).to be_falsey
      end
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

  describe '#mint' do
    let(:target_url) { nil }
    let(:doi_state) { :draft }
    let(:minted_doi) { datacite.mint(digital_object: digital_object, target_url: target_url, doi_state: doi_state) }
    context "no DigitalObject supplied" do
      let(:digital_object) { nil }
      let(:rest_api_response_body) { no_metadata_response_body_json }
      let(:rest_api_response_status) { 201 }
      it "calls the appropriate Api method" do
        expect(rest_api).to receive(:post_dois).with(kind_of(String)).and_return(rest_api_response)
        expect(minted_doi).to eql("10.33555/tb9q-qb07")
      end
      context "and status is not draft" do
        let(:doi_state) { :findable }
        it "returns nil" do
          expect(minted_doi).to be_nil
        end
      end
    end

    context "DigitalObject supplied" do
      let(:target_url) { 'https://www.columbia.edu' }
      let(:rest_api_response_body) { no_metadata_response_body_json }
      let(:rest_api_response_status) { 201 }
      it "calls the appropriate Api method" do
        expect(rest_api).to receive(:post_dois).with(kind_of(String)).and_return(rest_api_response)
        expect(minted_doi).to eql("10.33555/tb9q-qb07")
      end
      context "and status is not draft" do
        let(:doi_state) { :findable }
        it "alls the appropriate Api method" do
          expect(rest_api).to receive(:post_dois).with(kind_of(String)).and_return(rest_api_response)
          expect(minted_doi).to eql("10.33555/tb9q-qb07")
        end
      end
    end
  end

  describe '#update' do
    let(:doi) { '10.33555/tb9q-qb07' }
    let(:rest_api_response_body) { no_metadata_response_body_json }
    let(:rest_api_response_status) { 200 }
    it "calls the appropriate Api method" do
      expect(rest_api).to receive(:put_dois).with(doi, kind_of(String)).and_return(rest_api_response)
      expect(datacite.update(doi, digital_object: digital_object, location_uri: 'https://www.columbia.edu')).to be true
    end
  end

  describe '#update_location_uri' do
    let(:doi) { '10.33555/tb9q-qb07' }
    let(:rest_api_response_body) { no_metadata_response_body_json }
    let(:rest_api_response_status) { 200 }
    it "calls the appropriate Api method" do
      expect(rest_api).to receive(:put_dois).with(doi, kind_of(String)).and_return(rest_api_response)
      datacite.update_location_uri(doi, 'https://www.columbia.edu')
    end
  end
end
