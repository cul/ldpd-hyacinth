module Hyacinth
  module Storage
    module AbstractStorage
      def initialize(config)
        raise 'Missing config option: storage_adapters' if adapter_config[:storage_adapters].blank?
        @storage_adapters = config[:storage_adapters].map{ |storage_adapter_config| Hyacinth::Adapters::StorageAdapter.create(storage_adapter_config) }
      end

      # The primary storage adapter is always the first storage adapter in the storage adapters list
      def primary_storage_adapter
        @storage_adapters.first
      end

      def read(location)
        storage_adapter_for_location.read(location)
      end

      def write(location, content)
        storage_adapter_for_location.read(location, content)
      end

      # Returns the first compatible storage adapter for the given location, or nil if no compatible storage adapter is found.
      def storage_adapter_for_location(location)
       @storage_adapters.find { |adapter| adapter.handles?(location) }
      end
    end
  end
end
