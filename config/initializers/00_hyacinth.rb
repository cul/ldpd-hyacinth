# Load config from hyacinth.yml
HYACINTH = Rails.application.config_for(:hyacinth).deep_symbolize_keys

# Register supported Storage Adapters
Hyacinth::Adapters::StorageAdapterManager.register(:disk, Hyacinth::Adapters::StorageAdapter::Disk)
Hyacinth::Adapters::StorageAdapterManager.register(:memory, Hyacinth::Adapters::StorageAdapter::Memory)

# Register supported Search Adapters
Hyacinth::Adapters::SearchAdapterManager.register(:solr, Hyacinth::Adapters::SearchAdapter::Solr)

# Register supported Lock Adapters
Hyacinth::Adapters::LockAdapterManager.register(:database_entry_lock, Hyacinth::Adapters::LockAdapter::DatabaseEntryLock)

Rails.application.config.to_prepare do
  # Set up Hyaicnth config object on Hyacinth module

  module Hyacinth
    def self.config
      @config ||= begin
        Struct.new(
          :digital_object_types,
          :metadata_storage,
          :resource_storage,
          :search_adapter,
          :lock_adapter
        ) { }.new(
          Hyacinth::DigitalObject::Types.new(
            'item' => ::DigitalObject::Item,
            'asset' => ::DigitalObject::Asset,
            'site' => ::DigitalObject::Site
          ),
          Hyacinth::Storage::MetadataStorage.new(HYACINTH[:metadata_storage]),
          Hyacinth::Storage::ResourceStorage.new(HYACINTH[:resource_storage]),
          Hyacinth::Adapters::SearchAdapterManager.create(HYACINTH[:search_adapter]),
          Hyacinth::Adapters::LockAdapterManager.create(HYACINTH[:lock_adapter]),
        )
      end
    end
  end
end
