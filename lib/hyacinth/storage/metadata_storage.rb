# frozen_string_literal: true

module Hyacinth
  module Storage
    class MetadataStorage < AbstractStorage
      def initialize(config)
        super(config)
      end

      # Uses the primary metadata storage adapter to generate a new storage location
      # for the given uid, ensuring that nothing currently exists at that location.
      # @param uid [String] uid of an object
      # @return [String] a location uri
      delegate :generate_new_location_uri, to: :primary_storage_adapter
    end
  end
end
