# frozen_string_literal: true

module Hyacinth
  module Storage
    class ResourceStorage < AbstractStorage
      def initialize(config)
        managed_storage_adapters = config[:managed_storage_adapters]
        tracked_storage_adapters = config[:tracked_storage_adapters]

        raise 'Missing config option: managed_storage_adapters' if managed_storage_adapters.blank?
        raise 'Missing config option: tracked_storage_adapters' if tracked_storage_adapters.blank?

        @primary_managed_storage_adapter = Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::StorageAdapter', managed_storage_adapters.first)
        @primary_tracked_storage_adapter = Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::StorageAdapter', tracked_storage_adapters.first)

        # Combine adapter configs to be compatible with generic abstract storage config
        super({ adapters: managed_storage_adapters + tracked_storage_adapters })
      end

      # Uses the primary MANAGED storage adapter to generate a new storage location
      # for the given uid and resource_name, ensuring that nothing currently exists
      # at that location.
      # @param uid [String] uid of an object
      # @param resouce_name [String] name of the resource (e.g. master, access, transcript, etc.)
      # @return [String] a location uri
      def generate_new_managed_location_uri(uid, resource_name)
        @primary_managed_storage_adapter.generate_new_location_uri("#{uid}-#{resource_name}")
      end

      # Uses the primary TRACKED storage adapter to generate a new storage location
      # for the given uid and resource_name, ensuring that nothing currently exists
      # at that location.
      # @param uid [String] uid of an object
      # @param resouce_name [String] name of the resource (e.g. master, access, transcript, etc.)
      # @return [String] a location uri
      def generate_new_tracked_location_uri(uid, resource_name)
        @primary_tracked_storage_adapter.generate_new_location_uri("#{uid}-#{resource_name}")
      end
    end
  end
end
