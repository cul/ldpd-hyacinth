module Hyacinth
  module Adapters
    module StorageAdapter
      # An adapter for storing and retrieving file records in memory.
      # There is no limit to how large this in-memory store can grow,
      # so be careful!
      class Memory < Abstract
        def initialize(adapter_config = {})
          super(adapter_config)
          @cache = {}
        end

        def uri_prefix
          "memory://"
        end

        # Generates a new storage location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(identifier)
          location_uri = "#{uri_prefix}#{identifier}"
          return location_uri unless exists?(location_uri)
          loop.with_index do |_, i|
            location_uri_variation = "#{location_uri}.#{i}"
            return location_uri_variation unless exists?(location_uri_variation)
          end
        end

        def exists?(location_uri)
          @cache.key?(location_uri)
        end

        def read_impl(location_uri)
          @cache[location_uri]
        end

        def write_impl(location_uri, content)
          @cache[location_uri] = content
        end
      end
    end
  end
end
