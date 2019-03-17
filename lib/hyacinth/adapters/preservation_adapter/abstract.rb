module Hyacinth
  module Adapters
    module PreservationAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of location_uri
        def handles?(location_uri)
          location_uri.start_with?(uri_prefix)
        end

        # Generates a new persistence location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(identifier)
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
          persist_impl(location_uri, digital_object)
        end

        def persist_impl
          raise NotImplementedError
        end
      end
    end
  end
end
