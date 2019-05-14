module Hyacinth
  module Adapters
    module StorageAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of location_uri
        def handles?(location_uri)
          location_uri.start_with?(uri_prefix)
        end

        # Generates a new storage location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(identifier)
          raise NotImplementedError
        end

        def exists?(location_uri)
          raise NotImplementedError
        end

        # @return [string] the expected prefix for a location_uri associated with this adapter ('disk://', 'memory://', etc.)
        def uri_prefix
          raise NotImplementedError
        end

        def read(location_uri)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          read_impl(location_uri)
        end

        def read_impl
          raise NotImplementedError
        end

        # @param location_uri [String] location to write to
        # @param content [bytes] content to write
        def write(location_uri, content)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          write_impl(location_uri, content)
        end

        def write_impl(*args)
          raise NotImplementedError
        end

        # @param location_uri [String] location to delete from
        def delete(location_uri)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          delete_impl(location_uri)
        end

        def delete_impl(*args)
          raise NotImplementedError
        end
      end
    end
  end
end
