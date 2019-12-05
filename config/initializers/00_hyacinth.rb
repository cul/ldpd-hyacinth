# frozen_string_literal: true

# Load config from hyacinth.yml
HYACINTH = Rails.application.config_for(:hyacinth).deep_symbolize_keys
# TODO: move into adapter config
DATACITE = Rails.application.config_for(:datacite).deep_symbolize_keys

# Register supported Storage Adapters
Hyacinth::Adapters::StorageAdapterManager.register(:disk, Hyacinth::Adapters::StorageAdapter::Disk)
Hyacinth::Adapters::StorageAdapterManager.register(:memory, Hyacinth::Adapters::StorageAdapter::Memory)

# Register supported Preservation Adapters
Hyacinth::Adapters::PreservationAdapterManager.register(:fedora3, Hyacinth::Adapters::PreservationAdapter::Fedora3)

# Register supported Search Adapters
Hyacinth::Adapters::SearchAdapterManager.register(:solr, Hyacinth::Adapters::SearchAdapter::Solr)

# Register supported Lock Adapters
Hyacinth::Adapters::LockAdapterManager.register(:database_entry_lock, Hyacinth::Adapters::LockAdapter::DatabaseEntryLock)

# Register supported Publication Adapters
Hyacinth::Adapters::PublicationAdapterManager.register(:hyacinth2, Hyacinth::Adapters::PublicationAdapter::Hyacinth2)
Hyacinth::Adapters::PublicationAdapterManager.register(:development, Hyacinth::Adapters::PublicationAdapter::Development)

# Register supported External ID Adapters
Hyacinth::Adapters::ExternalIdentifierAdapterManager.register(:datacite, Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite)
Hyacinth::Adapters::ExternalIdentifierAdapterManager.register(:memory, Hyacinth::Adapters::ExternalIdentifierAdapter::Memory)

Rails.application.config.to_prepare do
  # Set up Hyaicnth config object on Hyacinth module

  module Hyacinth
    def self.config
      @config ||= begin
        Struct.new(
          :digital_object_types,
          :metadata_storage,
          :resource_storage,
          :preservation_persistence,
          :search_adapter,
          :lock_adapter,
          :publication_adapter,
          :external_identifier_adapter,
          :term_search_adapter
        ) {}.new(
          Hyacinth::DigitalObject::Types.new(
            'item' => ::DigitalObject::Item,
            'asset' => ::DigitalObject::Asset,
            'site' => ::DigitalObject::Site
          ),
          Hyacinth::Storage::MetadataStorage.new(HYACINTH[:metadata_storage]),
          Hyacinth::Storage::ResourceStorage.new(HYACINTH[:resource_storage]),
          Hyacinth::Preservation::PreservationPersistence.new(HYACINTH[:preservation_persistence]),
          Hyacinth::Adapters::SearchAdapterManager.create(HYACINTH[:search_adapter]),
          Hyacinth::Adapters::LockAdapterManager.create(HYACINTH[:lock_adapter]),
          Hyacinth::Adapters::PublicationAdapterManager.create(HYACINTH[:publication_adapter]),
          Hyacinth::Adapters::ExternalIdentifierAdapterManager.create(HYACINTH[:external_identifier_adapter]),
          Hyacinth::Adapters::TermSearchAdapter::Solr.new(HYACINTH[:term_search_adapter])
        )
      end
    end
  end
end
