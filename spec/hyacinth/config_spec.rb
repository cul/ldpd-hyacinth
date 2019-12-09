# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Config do
  context ".digital_object_types" do
    it "returns an object of the expected type" do
      expect(described_class.digital_object_types).to be_a(Hyacinth::DigitalObject::Types)
    end
  end

  context ".metadata_storage" do
    it "returns an object of the expected type" do
      expect(described_class.metadata_storage).to be_a(Hyacinth::Storage::MetadataStorage)
    end
  end

  context ".resource_storage" do
    it "returns an object of the expected type" do
      expect(described_class.resource_storage).to be_a(Hyacinth::Storage::ResourceStorage)
    end
  end

  context ".preservation_persistence" do
    it "returns an object of the expected type" do
      expect(described_class.preservation_persistence).to be_a(Hyacinth::Preservation::PreservationPersistence)
    end
  end

  context ".digital_object_search_adapter" do
    it "returns an object of the expected type" do
      expect(described_class.digital_object_search_adapter).to be_a(Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr)
    end
  end

  context ".lock_adapter" do
    it "returns an object of the expected type" do
      expect(described_class.lock_adapter).to be_a(Hyacinth::Adapters::LockAdapter::DatabaseEntryLock)
    end
  end

  context ".publication_adapter" do
    it "returns an object of the expected type" do
      expect(described_class.publication_adapter).to be_a(Hyacinth::Adapters::PublicationAdapter::Hyacinth2)
    end
  end

  context ".external_identifier_adapter" do
    it "returns an object of the expected type" do
      expect(described_class.external_identifier_adapter).to be_a(Hyacinth::Adapters::ExternalIdentifierAdapter::Memory)
    end
  end

  context ".term_search_adapter" do
    it "returns an object of the expected type" do
      expect(described_class.term_search_adapter).to be_a(Hyacinth::Adapters::TermSearchAdapter::Solr)
    end
  end
end
