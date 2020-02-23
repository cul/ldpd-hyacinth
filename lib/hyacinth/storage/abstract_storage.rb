# frozen_string_literal: true

module Hyacinth
  module Storage
    class AbstractStorage
      def initialize(config)
        raise 'Missing config option: adapters' if config[:adapters].blank?
        raise ':adapters config option must be an array ' unless config[:adapters].is_a?(Array)
        @storage_adapters = config[:adapters].map do |adapter_config|
          Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::StorageAdapter', adapter_config)
        end
        # ensure that none of the storage adapters have the same uri_prefix
        uri_prefixes = Set.new
        @storage_adapters.each do |adapter|
          prefix = adapter.uri_prefix
          raise "Duplicate uri_prefix #{prefix} found for #{self.class}" if uri_prefixes.include?(prefix)
          uri_prefixes << prefix
        end
      end

      # The primary storage adapter is always the first storage adapter in the storage adapters list
      def primary_storage_adapter
        @storage_adapters.first
      end

      # NOTE: Probably want to stop using #write and switch entirely to #with_readable
      def read(location)
        # We don't need to establish a lock while reading, but we don't want to read if
        # a lock has already been established (e.g. by a write process).
        raise Hyacinth::Exceptions::LockError, "Cannot read #{location} because it is locked by another process." if Hyacinth::Config.lock_adapter.locked?(location)
        storage_adapter_for_location(location).read(location)
      end

      def with_readable(location, &block)
        # We don't need to establish a lock while reading, but we don't want to read if
        # a lock has already been established (e.g. by a write process).
        raise Hyacinth::Exceptions::LockError, "Cannot read #{location} because it is locked by another process." if Hyacinth::Config.lock_adapter.locked?(location)
        storage_adapter_for_location(location).with_readable(location, &block)
      end

      # NOTE: Probably want to stop using #write and switch entirely to #with_writable
      def write(location, content)
        Hyacinth::Config.lock_adapter.with_lock(location) do
          storage_adapter_for_location(location).write(location, content)
        end
      end

      def with_writable(location, &block)
        Hyacinth::Config.lock_adapter.with_lock(location) do
          storage_adapter_for_location(location).with_writable(location, &block)
        end
      end

      def exists?(location)
        storage_adapter_for_location(location).exists?(location)
      end

      # Returns the size in bytes of the file at the given location.
      def size(location)
        storage_adapter_for_location(location).size(location)
      end

      def delete(location)
        Hyacinth::Config.lock_adapter.with_lock(location) do
          storage_adapter_for_location(location).delete(location)
        end
      end

      # Returns the first compatible storage adapter for the given location, or nil if no compatible storage adapter is found.
      def storage_adapter_for_location(location)
        @storage_adapters.find { |ad| ad.handles?(location) } || (
          raise Hyacinth::Exceptions::AdapterNotFoundError,
                "Tried to find storage adapter for #{location}, but no adapter was found. "\
                "Known adapters: #{@storage_adapters.map(&:uri_prefix).join(', ')}"
        )
      end
    end
  end
end
