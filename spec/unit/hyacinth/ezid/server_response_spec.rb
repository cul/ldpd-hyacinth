require 'rails_helper'

describe Hyacinth::Ezid::ServerResponse do

  let(:expected_parsed_body) {
{"success"=>" doi:10.5072/FK27P90J1D", "_updated"=>" 1477929976", "_target"=>" http://ezid.cdlib.org/id/doi:10.5072/FK27P90J1D", "_profile"=>" datacite", "_ownergroup"=>" apitest", "_owner"=>" apitest", "_export"=>" yes", "_created"=>" 1477929976", "_status"=>" reserved", "_datacenter"=>" CDL.CDL"}
  }

  let(:sample_response_body) {
        "success: doi:10.5072/FK27P90J1D\n_updated: 1477929976\n_target: http://ezid.cdlib.org/id/doi:10.5072/FK27P90J1D\n_profile: datacite\n_ownergroup: apitest\n_owner: apitest\n_export: yes\n_created: 1477929976\n_status: reserved\n_datacenter: CDL.CDL\n"
  }

  let(:expected_doi) {
    'doi:10.5072/FK27P90J1D'
  }

  context "#parse_body" do
    it "correctly parses the body of the request" do
      dbl = double(Net::HTTPOK)
      allow(dbl).to receive(:body) { sample_response_body }
      ezid_server_response = Hyacinth::Ezid::ServerResponse.new dbl
      actual_parsed_body = ezid_server_response.parse_body
      expect(actual_parsed_body).to eq(expected_parsed_body)
    end
  end

  context "#doi" do
    it "doi" do
      dbl = double(Net::HTTPOK)
      allow(dbl).to receive(:body) { sample_response_body }
      ezid_server_response = Hyacinth::Ezid::ServerResponse.new dbl
      actual_doi = ezid_server_response.doi
      expect(actual_doi).to eq(expected_doi)
    end
  end
end
