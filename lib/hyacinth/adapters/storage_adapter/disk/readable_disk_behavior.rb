# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      module Disk
        module ReadableDiskBehavior
          extend ActiveSupport::Concern

          def readable?
            true
          end

          def exists?(location_uri)
            File.exist?(location_uri_to_file_path(location_uri))
          end

          def size(location_uri)
            File.size(location_uri_to_file_path(location_uri))
          end

          def read_impl(location_uri)
            IO.binread(location_uri_to_file_path(location_uri))
          end

          def readable_impl(location_uri, &block)
            file_path = location_uri_to_file_path(location_uri)
            open(file_path, 'rb') { |blob| block.yield(blob) }
          end

          def location_uri_to_file_path(location_uri)
            raise Hyacinth::Exceptions::InvalidLocationUri, 'Cannot resolve nil location_uri' if location_uri.nil?
            location_uri.gsub(/^#{uri_prefix}/, '')
          end
        end
      end
    end
  end
end
