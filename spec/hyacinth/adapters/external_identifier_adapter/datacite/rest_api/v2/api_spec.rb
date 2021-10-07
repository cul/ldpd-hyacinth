# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api do
  let(:api) { described_class.new(rest_api: 'https://api.test.datacite.org', user: 'FriendlyUser', password: 'FriendlyPassword') }
  let(:data) { Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new(prefix: '10.33555') }
  let(:expected_doi) { '10.33555/0645-3z82' }
  let(:rest_api_resource) { "https://api.test.datacite.org/dois/#{expected_doi}" }
  let(:expected_state) { 'draft' }
  let(:expected_url) { 'https://www.columbia.edu' }
  let(:metadata) do
    { type: 'dois',
      attributes: {
        doi: expected_doi,
        state: expected_state,
        titles: [{ title: 'The Good Title' }],
        creators: [{ name: "Doe, Jane" }],
        url: expected_url,
        publisher: 'Self',
        publicationYear: 2002,
        types: { resourceTypeGeneral: 'Text' },
        schemaVersion: 'http://datacite.org/schema/kernel-4',
        prefix: '10.33555'
      } }
  end

  let(:json_payload_update_doi) { JSON.generate(data: metadata) }

  let(:mocked_headers_with_content) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/vnd.api+json', 'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:mocked_headers_no_content) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Faraday v1.1.0' }
  end
  let(:api_response_body) { JSON.generate(data: metadata) }

  describe '#parse_doi_from_api_response_body' do
    it "parses the doi from the body of the API http response" do
      expect(api.parse_doi_from_api_response_body(api_response_body)).to eq(expected_doi)
    end
  end

  describe '#parse_state_from_api_response_body' do
    it "parses the state from the body of the API http response" do
      expect(api.parse_state_from_api_response_body(api_response_body)).to eq(expected_state)
    end
  end

  describe '#parse_url_from_api_response_body' do
    it "parses the target url from the body of the API http response" do
      expect(api.parse_url_from_api_response_body(api_response_body)).to eq(expected_url)
    end
  end

  describe '#get_doi' do
    let!(:mock_request) do
      stub_request(:get, "https://api.test.datacite.org/dois/#{expected_doi}").with(
        headers: mocked_headers_no_content
      ).to_return(status: 200, body: api_response_body, headers: {})
    end
    it "makes the expected request" do
      expect(api.get_doi(expected_doi).body).to eql(api_response_body)
      expect(mock_request).to have_been_requested.times(1)
    end
  end

  describe '#doi_exists?' do
    context "when a DOI exists" do
      let!(:mock_request) do
        stub_request(:get, rest_api_resource).with(
          headers: mocked_headers_no_content
        ).to_return(status: 200, body: '{}', headers: {})
      end
      it "returns true" do
        expect(api.doi_exists?(expected_doi)).to eq(true)
        expect(mock_request).to have_been_requested.times(1)
      end
    end

    context "when a DOI does not exist" do
      let!(:mock_request) do
        stub_request(:get, rest_api_resource).with(
          headers: mocked_headers_no_content
        ).to_return(status: 404, body: '{}', headers: {})
      end
      it "returns false" do
        expect(api.doi_exists?(expected_doi)).to eq(false)
        expect(mock_request).to have_been_requested.times(1)
      end
    end
  end

  describe '#doi_findable?' do
    context "when a DOI exists" do
      let!(:mock_request) do
        stub_request(:get, rest_api_resource).with(
          headers: mocked_headers_no_content
        ).to_return(status: 200, body: api_response_body, headers: {})
      end
      context "in the draft state" do
        let(:expected_state) { 'draft' }
        it "returns false" do
          expect(api.doi_findable?(expected_doi)).to eq(false)
          expect(mock_request).to have_been_requested.times(1)
        end
      end
      context "in the registered state" do
        let(:expected_state) { 'registered' }
        it "returns false" do
          expect(api.doi_findable?(expected_doi)).to eq(false)
          expect(mock_request).to have_been_requested.times(1)
        end
      end
      context "in the findable state" do
        let(:expected_state) { 'findable' }
        it "returns true" do
          expect(api.doi_findable?(expected_doi)).to eq(true)
          expect(mock_request).to have_been_requested.times(1)
        end
      end
    end

    context "when a DOI does not exist" do
      let!(:mock_request) do
        stub_request(:get, rest_api_resource).with(
          headers: mocked_headers_no_content
        ).to_return(status: 404, body: '{}', headers: {})
      end
      it "returns false" do
        expect(api.doi_findable?(expected_doi)).to eq(false)
        expect(mock_request).to have_been_requested.times(1)
      end
    end
  end

  describe '#create_doi' do
    let(:json_payload) { '{}' }
    let(:expected_body) { JSON.generate({}) }
    let!(:mock_request) do
      stub_request(:post, 'https://api.test.datacite.org/dois').with(
        headers: mocked_headers_with_content
      ).to_return(status: 201, body: expected_body, headers: {})
    end
    it "makes the expected request" do
      expect(api.create_doi(json_payload).body).to eql(expected_body)
      expect(mock_request).to have_been_requested.times(1)
    end
  end

  describe '#update_doi' do
    let(:expected_body) { JSON.generate({}) }
    let!(:mock_request) do
      stub_request(:put, 'https://api.test.datacite.org/dois/10.33555/2Y0J-BC24').with(
        body: json_payload_update_doi,
        headers: mocked_headers_with_content
      ).to_return(status: 200, body: expected_body, headers: {})
    end
    it "makes the expected request" do
      expect(api.update_doi('10.33555/2Y0J-BC24', json_payload_update_doi).body).to eql(expected_body)
      expect(mock_request).to have_been_requested.times(1)
    end
  end

  describe '#logger' do
    let(:dev) { StringIO.new }
    let(:log_level) { :warn }
    let(:logger_config) { { log_level: log_level, dev: dev } }
    let(:permitted_message) { 'Hello...' }
    let(:filtered_message) { 'Goodbye...' }
    let(:message_buffer) { dev.string.split }
    before do
      api.configure_logger(logger: logger_config)
      api.logger.warn(permitted_message)
      api.logger.info(filtered_message)
    end
    it "logs the api response" do
      expect(message_buffer).to include(permitted_message)
      expect(message_buffer).not_to include(filtered_message)
    end
  end
end
