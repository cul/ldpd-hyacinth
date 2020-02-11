# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class AbstractReadableWritable < AbstractReadable
        def initialize(adapter_config = {})
          raise 'Missing config option: uri_protocol' if adapter_config[:uri_protocol].blank?
          @uri_protocol = adapter_config[:uri_protocol]
        end

        # Important to override parent method's writable? method
        def writable?
          true
        end

        # Generates a new storage location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(_identifier)
          raise NotImplementedError
        end

        # @param location_uri [String] location to write to
        # @param content [bytes] content to write
        def write(location_uri, content)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          write_impl(location_uri, content)
        end

        def write_impl(*_args)
          raise NotImplementedError
        end

        def with_writeable(location_uri, &block)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          writeable_impl(location_uri, &block)
        end

        def writeable_impl(*_args)
          raise NotImplementedError
        end

        # @param location_uri [String] location to delete from
        def delete(location_uri)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          delete_impl(location_uri)
        end

        def delete_impl(*_args)
          raise NotImplementedError
        end
      end
    end
  end
end
