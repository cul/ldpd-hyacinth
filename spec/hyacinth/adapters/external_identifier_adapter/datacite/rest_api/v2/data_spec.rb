# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data do
  let(:data) { described_class.new('10.33555') }

  let(:expected_attributes_hash) do
    {
      creators: [{ name: "Mouse, Minnie" }, { name: "Mouse, Mickey" }],
      prefix: "10.33555",
      publicationYear: 2021,
      publisher: "Mouse Publishing",
      schemaVersion: "http://datacite.org/schema/kernel-4",
      titles: [{ title: "Mouse Hackers" }],
      types: { resourceTypeGeneral: "Text" },
      url: "www.example.com"
    }
  end

  let(:expected_json_payload) do
    '
    {"data":
       {"type":"dois",
        "attributes":
          {"prefix":"10.33555",
           "creators":
             [{"name":"Mouse, Minnie"},{"name":"Mouse, Mickey"}],
           "titles":
             [{"title":"Mouse Hackers"}],
           "publisher":"Mouse Publishing",
           "publicationYear":2021,
           "types":
             {"resourceTypeGeneral":"Text"},
           "url":"www.example.com",
           "schemaVersion":"http://datacite.org/schema/kernel-4"}
       }
    }
    '
  end

  before do
    data.creators = ['Mouse, Minnie', 'Mouse, Mickey']
    data.prefix = '10.33555'
    data.publisher = 'Mouse Publishing'
    data.publication_year = 2021
    data.resource_type_general = 'Text'
    data.title = 'Mouse Hackers'
    data.url = 'www.example.com'
  end

  describe "#add_properties_to_attributes_hash" do
    it " add the metadata to the attributes hash correctly" do
      # attributes set in the before clause
      data.add_properties_to_attributes_hash
      expect(data.attributes).to eql(expected_attributes_hash)
    end
  end

  describe "#build_mint" do
    it " builds mint payload as a hash (default: no metadata to be sent)" do
      data_mint = described_class.new('10.33555')
      data_mint.build_mint(:draft)
      expect(data_mint.data_hash).to eql(type: 'dois', attributes: { prefix: '10.33555' })
    end

    it " builds mint payload as a hash (with metadata set to true)" do
      # attributes set in the before clause
      data.build_mint(:draft, true)
      expect(data.data_hash).to eql(type: 'dois', attributes: expected_attributes_hash)
    end
  end

  describe "#build_properties_update" do
    it " builds an update payload as a hash, no state change" do
      # properties set in the before clause
      data.build_properties_update
      expect(data.data_hash).to eql(type: 'dois', attributes: expected_attributes_hash)
    end
    it " builds an update payload as a hash, state set to findable" do
      # properties set in the before clause
      data.build_properties_update(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: expected_attributes_hash.merge(event: 'publish'))
    end
  end

  describe "#build_state_update" do
    it " builds an state update payload as a hash, state set to findable" do
      data.build_state_update(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: { event: 'publish', prefix: '10.33555' })
    end
  end

  describe "#generate_json_payload" do
    it " builds an state update payload as a hash, state set to findable" do
      # attributes set in the before clause
      data.build_mint(:draft, true)
      expect(data.generate_json_payload).to eql(expected_json_payload.gsub(/\n\s+/, ''))
    end
  end

  describe '#add_event' do
    it " add the correct event for the given desired state" do
      data.add_event(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: { event: 'publish', prefix: '10.33555' })
    end
  end
end
