# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class TrackedDisk < Abstract
        include Disk::ReadableDiskBehavior

        def initialize(adapter_config = {})
          super(adapter_config)
        end

        # Prepends the uri_prefix of this storage adapter to the given location_without_prefix.
        # @param location_without_prefix [String] A location without a prefix. (e.g. a file path like /a/b/c.txt)
        # @return [String] a location uri that starts with a uri_prefix
        def generate_new_tracked_location_uri(location_without_uri_prefix)
          uri_prefix + location_without_uri_prefix
        end
      end
    end
  end
end
