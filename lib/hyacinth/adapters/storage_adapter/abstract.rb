# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class Abstract
        def initialize(adapter_config = {})
          raise 'Missing config option: uri_protocol' if adapter_config[:uri_protocol].blank?
          @uri_protocol = adapter_config[:uri_protocol]
        end

        def readable?
          false
        end

        def writable?
          false
        end

        # @return [string] the expected prefix for a location_uri associated with this adapter
        def uri_prefix
          "#{@uri_protocol}://"
        end

        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of location_uri
        def handles?(location_uri)
          return false if location_uri.nil?
          location_uri.start_with?(uri_prefix)
        end

        def exists?(_location_uri)
          raise NotImplementedError
        end

        def read(location_uri)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          read_impl(location_uri)
        end

        def read_impl
          raise NotImplementedError
        end

        def with_readable(location_uri, &block)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          readable_impl(location_uri, &block)
        end

        def readable_impl(*_args)
          raise NotImplementedError
        end

        ##########################
        # Writable methods below #
        ##########################

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

        def with_writable(location_uri, &block)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled location_uri for #{self.class.name}: #{location_uri}" unless handles?(location_uri)
          writable_impl(location_uri, &block)
        end

        def writable_impl(*_args)
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
