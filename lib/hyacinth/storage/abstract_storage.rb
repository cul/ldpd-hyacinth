module Hyacinth
  module Storage
    class AbstractStorage
      def initialize(config)
        raise 'Missing config option: adapters' if config[:adapters].blank?
        @storage_adapters = config[:adapters].map do |adapter_config|
          Hyacinth::Adapters::StorageAdapterManager.create(adapter_config)
        end
      end

      # The primary storage adapter is always the first storage adapter in the storage adapters list
      def primary_storage_adapter
        @storage_adapters.first
      end

      def read(location)
        storage_adapter_for_location(location).read(location)
      end

      def write(location, content)
        storage_adapter_for_location(location).write(location, content)
      end

      def exists?(location)
        storage_adapter_for_location(location).exists?(location)
      end

      def delete(location)
        storage_adapter_for_location(location).delete(location)
      end

      # Returns the first compatible storage adapter for the given location, or nil if no compatible storage adapter is found.
      def storage_adapter_for_location(location)
        @storage_adapters.find { |adapter| adapter.handles?(location) }
      end
    end
  end
end
