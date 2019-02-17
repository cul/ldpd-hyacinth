module Hyacinth
  module Adapters
    module StorageAdapter
      class Disk < Abstract
        def initialize(adapter_config = {})
          super(adapter_config)
        end

        def uri_prefix
          "disk://"
        end

        # Generates a new storage location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(identifier)
          location_uri = uri_prefix + File.join(Hyacinth::Utils::HashPath.hash_path(@base_path, identifier))
          return location_uri unless exists?(location_uri)
          loop.with_index do |_, i|
            location_uri_variation = "#{location_uri}.#{i}"
            return location_uri_variation unless exists?(location_uri_variation)
          end
        end

        def exists?(location_uri)
          File.exist?(location_uri_to_file_path(location_uri))
        end

        def read_impl(location_uri)
          IO.binread(location_uri_to_file_path(location_uri))
        end

        def write_impl(location_uri, content)
          file_path = location_uri_to_file_path(location_uri)
          FileUtils.mkdir_p(File.dirname(file_path))
          IO.binwrite(file_path, content)
        end

        def location_uri_to_file_path(location_uri)
          location_uri.gsub(/^#{uri_prefix}/, '')
        end
      end
    end
  end
end
