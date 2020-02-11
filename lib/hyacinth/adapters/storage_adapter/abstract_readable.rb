# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class AbstractReadable
        def initialize(adapter_config = {})
          raise 'Missing config option: uri_protocol' if adapter_config[:uri_protocol].blank?
          @uri_protocol = adapter_config[:uri_protocol]
        end

        def readable?
          true
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
      end
    end
  end
end
