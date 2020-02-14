# frozen_string_literal: true

module Hyacinth
  module Storage
    class CsvImportStorage < AbstractStorage
      def initialize(config)
        super(config)
      end

      # Uses the primary csv import storage adapter to generate a new storage location
      # for the given identifier, ensuring that nothing currently exists at that location.
      # @param uid [String] identifier
      # @return [String] a location uri
      def generate_new_location_uri(identifier)
        primary_storage_adapter.generate_new_location_uri(identifier)
      end
    end
  end
end
