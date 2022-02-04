require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Datacite::ApiSession do
  subject { described_class.new(EZID[:user],EZID[:password]) }

  let(:data) {
    {"_status"=>"reserved"}
  }

  let(:expected_anvl) {
    '_status: reserved'
  }

  let(:sample_response_body_json) do
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

  let(:sample_update_attributes) do
    { titles: [{ title: "The Good Title" }],
      creators: [{ name: "Doe, Jane" }],
      url: "https://www.columbia.edu",
      publisher: "Self",
      publicationYear: 2002,
      types: { resourceTypeGeneral: "Text" },
      schemaVersion: "http://datacite.org/schema/kernel-4"
    }
  end

  let(:expected_attributes_parameter) do
    {
      :titles => [{:title => "The Good Title"}],
      :creators => [{:name=>"Doe, Jane"}],
      :url => "https://www.columbia.edu",
      :publisher => "Self",
      :publicationYear => 2002,
      :types => {:resourceTypeGeneral=>"Text"},
      :schemaVersion => "http://datacite.org/schema/kernel-4",
      :prefix => nil,
      :event=>nil
    }
  end

  context "mint_identifier" do
    let(:response) { instance_double(Net::HTTPResponse, body: sample_response_body_json) }
    before do
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:call_api).with(instance_of(URI::HTTPS),
                                                                                       instance_of(Net::HTTP::Post),
                                                                                       {prefix: "10.33555"} ).and_return response
    end
    it "mint identifier" do
      subject.mint_identifier('10.33555',:draft)
    end
  end

  context "modify_identifier" do
    let(:response) { instance_double(Net::HTTPResponse, body: sample_response_body_json) }
    before do
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:call_api).with(instance_of(URI::HTTPS),
                                                                                       instance_of(Net::HTTP::Put),
                                                                                       expected_attributes_parameter ).and_return response
    end
    it "modify identifier" do
      subject.modify_identifier('10.33555/5x55-t644',
                                :findable,
                                sample_update_attributes,
                                'https://www.columbia.edu')
    end
  end
end
