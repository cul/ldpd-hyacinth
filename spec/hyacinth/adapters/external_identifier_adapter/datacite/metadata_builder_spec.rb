# frozen_string_literal: true

require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::MetadataBuilder do
  let(:metadata_builder) { described_class.new metadata_retrieval }

  let(:metadata_retrieval) { Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata.new dod }

  let(:schema_source) { file_fixture('files/datacite/xsd/kernel-3.xsd') }
  let(:schema) do
    Nokogiri::XML::Schema(open(schema_source.realpath))
  end

  let(:datacite_xml) { metadata_builder.datacite_xml }

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
        JSON.parse(file_fixture('files/datacite/ezid_item.json').read)
      end
      let(:expected_xml) do
        Nokogiri::XML(file_fixture('files/datacite/datacite.xml').read)
      end

      it "produces the expected XML serialization" do
        expect(Nokogiri::XML(datacite_xml)).to be_equivalent_to(expected_xml)
      end

      it "produces a valid XML serialization" do
        # using a more verbose form to get a list of errors
        # but functionally equivalent to
        #   expect(schema).to be_valid(Nokogiri::XML(datacite_xml))
        expect(schema.validate(Nokogiri::XML(datacite_xml))).to be_empty
      end
    end
    context "dynamic fields -- genre not mapped to datacite resource type" do
      before do
        # sanity check
        expect(schema).to be_valid(expected_xml)
      end
      let(:dod) do
        JSON.parse(file_fixture('files/datacite/ezid_item_datacite_unmapped_genre.json').read)
      end
      let(:expected_xml) do
        Nokogiri::XML(file_fixture('files/datacite/datacite_unmapped_genre.xml').read)
      end

      it "produces the expected XML serialization" do
        expect(datacite_xml).to be_equivalent_to(expected_xml)
      end

      it "produces a valid XML serialization" do
        # using a more verbose form to get a list of errors
        # but functionally equivalent to
        #   expect(schema).to be_valid(Nokogiri::XML(datacite_xml))
        expect(schema.validate(Nokogiri::XML(datacite_xml))).to be_empty
      end
    end
    context "empty dynamic fields" do
      let(:dod) do
        JSON.parse(file_fixture('files/datacite/ezid_item_empty_descriptive_metadata.json').read)
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
        JSON.parse(file_fixture('files/datacite/ezid_item_minimal_descriptive_metadata.json').read)
      end
      let(:expected_xml) do
        xml = file_fixture('files/datacite/datacite_minimal.xml').read
        Nokogiri::XML(xml.gsub('item.001', unique_id))
      end

      it "produces the expected XML serialization" do
        expect(datacite_xml).to be_equivalent_to(expected_xml)
      end

      it "produces a valid XML serialization" do
        # using a more verbose form to get a list of errors
        # but functionally equivalent to
        #   expect(schema).to be_valid(Nokogiri::XML(datacite_xml))
        expect(schema.validate(Nokogiri::XML(datacite_xml))).to be_empty
      end
    end
  end
end
