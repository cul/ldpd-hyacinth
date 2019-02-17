#################################
# Load config from hyacinth.yml #
#################################
HYACINTH = Rails.application.config_for(:hyacinth).deep_symbolize_keys

Rails.application.config.after_initialize do
  ###############################
  # Register supported Adapters #
  ###############################

  # Storage adapters
  Hyacinth::Adapters::StorageAdapter.register(:disk, Hyacinth::Adapters::StorageAdapter::Disk)
  Hyacinth::Adapters::StorageAdapter.register(:memory, Hyacinth::Adapters::StorageAdapter::Memory)

  # Search adapters
  Hyacinth::Adapters::SearchAdapter.register(:solr, Hyacinth::Adapters::SearchAdapter::Solr)

  # Lock adapters
  Hyacinth::Adapters::LockAdapter.register(:database_entry_lock, Hyacinth::Adapters::LockAdapter::DatabaseEntryLock)

  ####################################################
  # Set up Hyaicnth config object on Hyacinth module #
  ####################################################
  module Hyacinth
    def self.config
      @config ||= begin
        # Create config, setting default adapters based on current environment (via hyacinth.yml)
        Struct.new(
          :digital_object_types,
          :metadata_storage,
          :resource_storage,
          :search_adapter,
          :lock_adapter
        ) { }.new(
          Hyacinth::DigitalObject::Types.new,
          Hyacinth::Storage::MetadataStorage.new(HYACINTH[:metadata_storage]),
          Hyacinth::Storage::ResourceStorage.new(HYACINTH[:resource_storage]),
          Hyacinth::Adapters::SearchAdapter.create(HYACINTH[:search_adapter]),
          Hyacinth::Adapters::LockAdapter.create(HYACINTH[:lock_adapter]),
        ).tap do |cfg|
          # Register supported Digital Object Types
          cfg.digital_object_types.register('item', ::DigitalObject::Item)
          cfg.digital_object_types.register('asset', ::DigitalObject::Asset)
          cfg.digital_object_types.register('site', ::DigitalObject::Site)
        end
      end
    end
  end
end
