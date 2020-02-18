# frozen_string_literal: true

module Hyacinth
  module Storage
    class CsvExportStorage < AbstractStorage
      def initialize(config)
        super(config)
      end

      # Uses the primary csv export storage adapter to generate a new storage location
      # for the given identifier, ensuring that nothing currently exists at that location.
      # @param uid [String] identifier
      # @return [String] a location uri
      delegate :generate_new_location_uri, to: :primary_storage_adapter
    end
  end
end
