require 'rails_helper'

describe Hyacinth::Datacite::ServerResponse do

  let(:expected_doi) { 'doi:10.33555/s3av-zq08' }

  let(:sample_response_body) {
    ' { "data" :
        { "id" : "10.33555/s3av-zq08",
          "type" : "dois",
          "attributes" :
            { "doi" : "10.33555/s3av-zq08",
              "prefix":"10.33555",
              "suffix":"s3av-zq08"
            }
        }
    } '
  }

  let(:sample_response_with_error) { '{"errors":[{"status":"404","title":"The resource you are looking for does not exist."}]}' }

  let(:expected_parsed_body) { }

  context "#doi" do
    it "doi" do
      dbl = double(Net::HTTPOK)
      allow(dbl).to receive(:body) { sample_response_body }
      datacite_server_response = Hyacinth::Datacite::ServerResponse.new dbl
      actual_doi = datacite_server_response.doi
      expect(actual_doi).to eq(expected_doi)
    end
  end
  context "#error" do
    it "error" do
      dbl = double(Net::HTTPOK)
      allow(dbl).to receive(:body) { sample_response_with_error }
      datacite_server_response = Hyacinth::Datacite::ServerResponse.new dbl
      expect(datacite_server_response.error?).to eq(true)
    end
  end
end
