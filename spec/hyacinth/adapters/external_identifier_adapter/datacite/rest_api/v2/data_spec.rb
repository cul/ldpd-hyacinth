# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data do
  let(:expected_url) { "www.example.com" }
  let(:prefix) { '10.33555' }
  let(:default_properties) { {} }
  let(:data) { described_class.new(prefix: prefix, default_properties: default_properties) }

  let(:all_required_properties) do
    {
      prefix: "10.33555",
      creators: [{ name: "Mouse, Minnie" }, { name: "Mouse, Mickey" }],
      publicationYear: 2021,
      publisher: "Mouse Publishing",
      titles: [{ title: "Mouse Hackers" }],
      types: { resourceTypeGeneral: "Text" },
      url: expected_url
    }
  end

  let(:all_metadata_attributes_hash) do
    { schemaVersion: "http://datacite.org/schema/kernel-4" }.merge(all_required_properties)
  end

  let(:no_metadata_attributes_hash) do
    {
      prefix: "10.33555",
      schemaVersion: "http://datacite.org/schema/kernel-4"
    }
  end

  shared_context "default metadata set" do
    let(:datacite_properties) do
      {
        creators: [{ name: 'Mouse, Minnie' }, { name: 'Mouse, Mickey' }],
        publisher: 'Mouse Publishing',
        publicationYear: 2021,
        types: { resourceTypeGeneral: 'Text' },
        titles: [{ title: 'Mouse Hackers' }]
      }
    end
    before do
      expect(Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata).to receive(:as_datacite_properties).and_return(datacite_properties)
    end
  end

  describe "#initialize" do
    it "sets instance variables correctly" do
      new_data = described_class.new(prefix: '10.33555')
      expect(new_data.prefix).to eql('10.33555')
      expect(new_data.default_properties).to eql({})
    end
  end

  describe "#digital_object_properties_as_attributes" do
    let(:digital_object) { nil }
    let(:attributes) { data.digital_object_properties_as_attributes(digital_object) }
    context "has metadata" do
      let(:digital_object) { DigitalObject::Item.new }
      include_context "default metadata set"
      it "add the metadata to the attributes hash correctly" do
        expect(attributes).to eql(all_metadata_attributes_hash.except(:url))
      end
    end
    it "constructs the attributes hash correctly if metadata not supplied" do
      expect(attributes).to eql(no_metadata_attributes_hash)
    end
  end

  describe "#build_mint" do
    let(:data) { described_class.new(prefix: '10.33555') }
    let(:digital_object) { nil }
    let(:state) { :draft }
    let(:payload_json) { data.build_mint(digital_object, state) }
    let(:payload) { JSON.parse(payload_json) }
    it "builds mint payload as a hash (default: no metadata to be sent)" do
      expect(payload).to eql('data' => { 'type' => 'dois', 'attributes' => no_metadata_attributes_hash.stringify_keys })
    end

    context "has metadata and url" do
      include_context "default metadata set"
      let(:digital_object) { DigitalObject::Item.new }
      let(:attributes) { all_metadata_attributes_hash }
      let(:payload_json) { data.build_mint(digital_object, state, expected_url) }
      let(:expected_payload_json) do
        JSON.dump(data: { type: 'dois', attributes: attributes })
      end
      let(:expected_payload) { JSON.parse(expected_payload_json) }
      it "builds mint payload as a hash (with metadata set)" do
        expect(payload).to eql(expected_payload)
      end
      context "set to findable" do
        let(:state) { :findable }
        let(:attributes) { all_metadata_attributes_hash.merge(event: :publish) }
        it "builds an state update payload as a hash, state set to findable" do
          expect(payload).to eql(expected_payload)
        end
      end
    end
  end

  describe "#build_properties_update" do
    include_context "default metadata set"
    let(:digital_object) { DigitalObject::Item.new }
    let(:payload) { JSON.parse(payload_json) }
    let(:expected_payload) { JSON.parse(JSON.dump(data: { type: 'dois', attributes: attributes })) }

    context 'no state change' do
      let(:attributes) { all_metadata_attributes_hash }
      let(:payload_json) { data.build_properties_update(digital_object, nil, expected_url) }
      it "builds an update payload as a hash, no state change" do
        data.build_properties_update
        expect(payload).to eql(expected_payload)
      end
    end
    context 'state change' do
      let(:attributes) { all_metadata_attributes_hash.merge(event: 'publish') }
      let(:payload_json) { data.build_properties_update(digital_object, :findable, expected_url) }
      it "builds an update payload as a hash, state set to findable" do
        expect(payload).to eql(expected_payload)
      end
    end
  end

  describe "#build_state_update" do
    let(:payload_json) { data.build_state_update(:findable) }
    let(:payload) { JSON.parse(payload_json) }
    let(:expected_payload) do
      JSON.parse(JSON.dump(data: { type: 'dois', attributes: no_metadata_attributes_hash.merge(event: 'publish') }))
    end
    it "builds an state update payload as a hash, state set to findable" do
      data.build_state_update(:findable)
      expect(payload).to eql(expected_payload)
    end
  end

  describe "#all_required_properties_present?" do
    let(:missing_properties) { all_required_properties.except(missing_property) }
    it "returns true if all required properties are present" do
      expect(data.all_required_properties_present?(all_required_properties)).to be true
    end
    shared_examples "a property is missing" do
      it "returns false" do
        properties = all_required_properties.except(missing_property)
        expect(data.missing_required_properties(properties)).to eql([missing_property])
        expect(data.all_required_properties_present?(properties)).to be false
      end
    end
    context "prefix is missing" do
      let(:missing_property) { :prefix }
      include_examples "a property is missing"
    end
    context "titles is missing" do
      let(:missing_property) { :titles }
      include_examples "a property is missing"
    end
    context "creators is missing" do
      let(:missing_property) { :creators }
      include_examples "a property is missing"
    end
    context "publisher is missing" do
      let(:missing_property) { :publisher }
      include_examples "a property is missing"
    end
    context "publicationYear is missing" do
      let(:missing_property) { :publicationYear }
      include_examples "a property is missing"
    end
    context "types is missing" do
      let(:missing_property) { :types }
      include_examples "a property is missing"
    end
    context "url is missing" do
      let(:missing_property) { :url }
      include_examples "a property is missing"
    end
  end
end
