# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of location_uri
        def handles?(location_uri)
          return false if location_uri.nil?
          location_uri.start_with?(uri_prefix)
        end

        # Generates a new persistence identifier, ensuring that no object exists for the new URI.
        # @return [String] a location uri
        def generate_new_location_uri
          raise NotImplementedError
        end

        # Returns true if an object exists in a persistence system at the given location_uri
        def exists?(location_uri)
          raise NotImplementedError
        end

        # @return [string] the expected prefix for a location_uri associated with this adapter ('fedora3://', 'fedora4://', etc.)
        def uri_prefix
          raise NotImplementedError
        end

        def persist(location_uri, digital_object)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          raise Hyacinth::Exceptions::InvalidPersistConditions, "Persistence requires DOI" unless digital_object.ensure_doi!
          persist_impl(location_uri, digital_object)
        end

        def persist_impl
          raise NotImplementedError
        end
      end
    end
  end
end
