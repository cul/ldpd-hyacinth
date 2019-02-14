module Hyacinth
  module Storage
    class ResourceStorage < AbstractStorage
      def initialize(config)
        super(config)
      end

      # Uses the primary metadata storage adapter to generate a new storage location
      # for the given uid and resource_name, ensuring that nothing currently exists
      # at that location.
      # @param uid [String] uid of an object
      # @param resouce_name [String] name of the resource (e.g. master, access, transcript, etc.)
      # @return [String] a location uri
      def generate_new_location_uri(uid, resource_name)
        primary_storage_adapter.generate_new_location_uri("#{uid}-#{resource_name}")
      end
    end
  end
end
