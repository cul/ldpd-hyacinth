require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Ezid::DataciteMetadataBuilder do

  let(:metadata_builder) { described_class.new metadata_retrieval }

  let(:metadata_retrieval) { Hyacinth::Ezid::HyacinthMetadata.new dod }

  let(:schema) do
     Nokogiri::XML::Schema(fixture('xsd/datacite/kernel-3.xsd'))
  end

  context "#datacite_xml" do
    let(:unique_id) { 'item.' + SecureRandom.uuid }
    before do
      # random identifer to avoid collisions
      dod['identifiers'] = [unique_id]
    end
    context "dynamic fields" do
      before do
        # sanity check
        expect(schema).to be_valid(expected_xml)
      end
      let(:dod) do
        JSON.parse( fixture('lib/hyacinth/ezid/ezid_item.json').read )
      end
      let(:expected_xml) do
        Nokogiri::XML(fixture('lib/hyacinth/ezid/datacite.xml').read)
      end

      subject { metadata_builder.datacite_xml }

      it "produces the expected XML serialization" do
        expect(subject).to be_equivalent_to(expected_xml)
      end

      it "produces a valid XML serialization" do
        # using a more verbose form to get a list of errors
        # but functionally equivalent to
        #   expect(schema).to be_valid(Nokogiri::XML(subject))
        expect(schema.validate(Nokogiri::XML(subject))).to be_empty
      end
    end
    context "empty dynamic fields" do
      let(:dod) do
        JSON.parse( fixture('lib/hyacinth/ezid/ezid_item_empty_dynamic_field_data.json').read )
      end
      it "produce a valid XML serialization with creator = '(:unav)' when creator isn't present" do
        expect(metadata_builder.datacite_xml).to include('<creatorName>(:unav)</creatorName>')
      end
    end
    context "minimal dynamic fields" do
      before do
        # sanity check
        expect(schema).to be_valid(expected_xml)
      end

      let(:dod) do
        JSON.parse( fixture('lib/hyacinth/ezid/ezid_item_minimal_dynamic_field_data.json').read )
      end
      let(:expected_xml) do
        xml = fixture('lib/hyacinth/ezid/datacite_minimal.xml').read
        Nokogiri::XML(xml.gsub('item.001', unique_id))
      end

      subject { metadata_builder.datacite_xml }
      it "produces the expected XML serialization" do
        expect(subject).to be_equivalent_to(expected_xml)
      end
      it "produces a valid XML serialization" do
        # using a more verbose form to get a list of errors
        # but functionally equivalent to
        #   expect(schema).to be_valid(Nokogiri::XML(subject))
        expect(schema.validate(Nokogiri::XML(subject))).to be_empty
      end
    end
  end
end
