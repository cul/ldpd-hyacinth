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

  let(:properties_hash) do
    {
      creators: ["Mouse, Minnie", "Mouse, Mickey"],
      publication_year: 2021,
      publisher: "Mouse Publishing",
      title: "Mouse Hackers",
      resource_type_general: "Text",
      url: "www.example.com"
    }
  end

  let(:no_metadata_expected_attributes_hash) do
    {
      prefix: "10.33555",
      schemaVersion: "http://datacite.org/schema/kernel-4"
    }
  end

  let(:expected_json_payload) do
    '
    {"data":
       {"type":"dois",
        "attributes":
          {"prefix":"10.33555",
           "schemaVersion":"http://datacite.org/schema/kernel-4",
           "creators":
             [{"name":"Mouse, Minnie"},{"name":"Mouse, Mickey"}],
           "titles":
             [{"title":"Mouse Hackers"}],
           "publisher":"Mouse Publishing",
           "publicationYear":2021,
           "types":
             {"resourceTypeGeneral":"Text"},
           "url":"www.example.com"}
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

  describe "#initialize" do
    it "sets instance variable correctly" do
      new_data = described_class.new('10.33555')
      expect(new_data.prefix).to eql('10.33555')
    end
  end

  describe "#add_properties_to_attributes_hash" do
    it "add the metadata to the attributes hash correctly" do
      # attributes set in the before clause
      data.add_properties_to_attributes_hash
      expect(data.attributes).to eql(expected_attributes_hash)
    end
    it "constructs the attributes hash correctly if metadata not supplied" do
      data_with_no_metadata = described_class.new('10.33555')
      data_with_no_metadata.add_properties_to_attributes_hash
      expect(data_with_no_metadata.attributes).to eql(no_metadata_expected_attributes_hash)
    end
  end

  describe "#update_properties" do
    it "updates the properties correct given a populated properties hash" do
      data.update_properties properties_hash
      expect(data.title).to eql("Mouse Hackers")
      expect(data.creators).to eql(["Mouse, Minnie", "Mouse, Mickey"])
      expect(data.publication_year).to be(2021)
      expect(data.publisher).to eql("Mouse Publishing")
      expect(data.resource_type_general).to eql("Text")
      expect(data.url).to eql("www.example.com")
    end
  end

  describe "#build_mint" do
    it "builds mint payload as a hash (default: no metadata to be sent)" do
      data_mint = described_class.new('10.33555')
      data_mint.build_mint(:draft)
      # expect(data_mint.data_hash).to eql(type: 'dois', attributes: { prefix: '10.33555' })
      expect(data_mint.data_hash).to eql(type: 'dois', attributes: no_metadata_expected_attributes_hash)
    end

    it "builds mint payload as a hash (with metadata set to true)" do
      # attributes set in the before clause
      # data.build_mint(:draft, true)
      data.build_mint(:draft)
      expect(data.data_hash).to eql(type: 'dois', attributes: expected_attributes_hash)
    end
  end

  describe "#build_properties_update" do
    it "builds an update payload as a hash, no state change" do
      # properties set in the before clause
      data.build_properties_update
      expect(data.data_hash).to eql(type: 'dois', attributes: expected_attributes_hash)
    end
    it "builds an update payload as a hash, state set to findable" do
      # properties set in the before clause
      data.build_properties_update(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: expected_attributes_hash.merge(event: 'publish'))
    end
  end

  describe "#build_state_update" do
    it "builds an state update payload as a hash, state set to findable" do
      data.build_state_update(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: no_metadata_expected_attributes_hash.merge(event: 'publish'))
    end
  end

  describe "#generate_json_payload" do
    it "builds an state update payload as a hash, state set to findable" do
      # attributes set in the before clause
      data.build_mint(:draft)
      expect(data.generate_json_payload).to eql(expected_json_payload.gsub(/\n\s+/, ''))
    end
  end

  describe "#all_required_properties_present?" do
    it "returns true if all required properties are present" do
      data.update_properties(properties_hash)
      expect(data.all_required_properties_present?).to be_truthy
    end
    it "returns false if the title required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:title))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
    it "returns false if the creators required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:creators))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
    it "returns false if the publisher required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:publisher))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
    it "returns false if the publication_year required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:publication_year))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
    it "returns false if the resource_type_general required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:resource_type_general))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
    it "returns false if the url required property is missing present" do
      data_no_title = described_class.new('10.33555')
      data_no_title.update_properties(properties_hash.except(:url))
      expect(data_no_title.all_required_properties_present?).to be_falsey
    end
  end

  describe '#add_event' do
    it "add the correct event for the given desired state" do
      data.add_event(:findable)
      expect(data.data_hash).to eql(type: 'dois',
                                    attributes: no_metadata_expected_attributes_hash.merge(event: 'publish'))
    end
  end
end
