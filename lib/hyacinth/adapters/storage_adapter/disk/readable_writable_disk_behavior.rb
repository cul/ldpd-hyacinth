# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      module Disk
        module ReadableWritableDiskBehavior
          extend ActiveSupport::Concern
          include ReadableDiskBehavior

          # Generates a new storage location for the given identifier, ensuring that nothing currently exists at that location.
          # @return [String] a location uri
          def generate_new_location_uri(identifier)
            location_uri = uri_prefix + File.join(Hyacinth::Utils::HashPath.hash_path(@default_path, identifier))
            return location_uri unless exists?(location_uri)
            loop.with_index do |_, i|
              location_uri_variation = "#{location_uri}.#{i}"
              return location_uri_variation unless exists?(location_uri_variation)
            end
          end

          def write_impl(location_uri, content)
            file_path = location_uri_to_file_path(location_uri)
            FileUtils.mkdir_p(File.dirname(file_path))
            IO.binwrite(file_path, content)
          end

          def writeable_impl(location_uri, &block)
            file_path = location_uri_to_file_path(location_uri)
            FileUtils.mkdir_p(File.dirname(file_path))
            open(file_path, 'wb') { |blob| block.yield(blob) }
          end

          def delete_impl(location_uri)
            File.delete(location_uri_to_file_path(location_uri)) if exists?(location_uri)
          end
        end
      end
    end
  end
end
