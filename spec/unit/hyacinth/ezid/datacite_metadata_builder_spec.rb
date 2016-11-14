require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Ezid::DataciteMetadataBuilder do

  let(:dod) {
    data = JSON.parse( fixture('lib/hyacinth/ezid/ezid_item.json').read )
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
  }

  before(:context) do

    @expected_xml = Nokogiri::XML(fixture('lib/hyacinth/ezid/datacite.xml').read)

  end

  context "#datacite_xml:" do
    
    it "datacite_xml" do
      metadata_retrieval = Hyacinth::Ezid::HyacinthMetadata.new dod
      metadata_builder = Hyacinth::Ezid::DataciteMetadataBuilder.new metadata_retrieval
      actual_xml = metadata_builder.datacite_xml
      expect(EquivalentXml.equivalent?(@expected_xml, actual_xml)).to eq(true)
      
    end

  end

end
