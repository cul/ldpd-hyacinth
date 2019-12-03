# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidResponse do
  let(:expected_parsed_body) do
    {
      "success" => " doi:10.5072/FK27P90J1D", "_updated" => " 1477929976",
      "_target" => " http://ezid.cdlib.org/id/doi:10.5072/FK27P90J1D",
      "_profile" => " datacite", "_ownergroup" => " apitest", "_owner" => " apitest",
      "_export" => " yes", "_created" => " 1477929976", "_status" => " reserved", "_datacenter" => " CDL.CDL"
    }
  end

  let(:sample_response_body) do
    [
      "success: doi:10.5072/FK27P90J1D",
      "_updated: 1477929976",
      "_target: http://ezid.cdlib.org/id/doi:10.5072/FK27P90J1D",
      "_profile: datacite",
      "_ownergroup: apitest",
      "_owner: apitest",
      "_export: yes",
      "_created: 1477929976",
      "_status: reserved",
      "_datacenter: CDL.CDL",
      ""
    ].join("\n")
  end

  let(:expected_doi) { 'doi:10.5072/FK27P90J1D' }

  let(:http_ok) { instance_double(Net::HTTPOK) }

  before { allow(http_ok).to receive(:body).and_return(sample_response_body) }

  context "#parse_body" do
    it "correctly parses the body of the request" do
      ezid_server_response = described_class.new http_ok
      actual_parsed_body = ezid_server_response.parse_body
      expect(actual_parsed_body).to eq(expected_parsed_body)
    end
  end

  context "#doi" do
    it "doi" do
      ezid_server_response = described_class.new http_ok
      actual_doi = ezid_server_response.doi
      expect(actual_doi).to eq(expected_doi)
    end
  end
end
