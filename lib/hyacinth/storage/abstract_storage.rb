module Hyacinth
  module Storage
    class AbstractStorage
      def initialize(config)
        raise 'Missing config option: adapters' if config[:adapters].blank?
        @storage_adapters = config[:adapters].map { |adapter_config| Hyacinth::Adapters::StorageAdapter.create(adapter_config) }
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
