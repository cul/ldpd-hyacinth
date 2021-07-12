# frozen_string_literal: true

require 'timeout'

module Hyacinth
  module Adapters
    module LockAdapter
      class DatabaseEntryLock < Abstract
        def initialize(adapter_config = {})
          super(adapter_config)
          raise 'Missing config option: lock_timeout' if adapter_config[:lock_timeout].blank?
          @lock_timeout = adapter_config[:lock_timeout].seconds
        end

        def locked?(key)
          ::DatabaseEntryLock.exists?(lock_key: key)
        end

        def lock(key)
          # Attempt to create a new lock
          LockObject.new(::DatabaseEntryLock.create!(lock_key: key, expires_at: DateTime.current + @lock_timeout), @lock_timeout)
        rescue ActiveRecord::RecordNotUnique
          # If we got here, there's an existing lock on this record. Let's examime that lock.
          database_entry_lock = ::DatabaseEntryLock.find_by(lock_key: key)

          if database_entry_lock.expires_at > DateTime.current
            # If the lock is still valid, based on expires_at time, then raise an exception.
            raise Hyacinth::Exceptions::LockError, "Lock on #{key} is currently held by another process."
          else
            # If the lock has expired, delete this lock entry and create a new one, then yield later in this method.
            begin
              database_entry_lock.destroy
              database_entry_lock = ::DatabaseEntryLock.create!(lock_key: key, expires_at: DateTime.current + @lock_timeout)
            rescue ActiveRecord::RecordNotUnique
              # It's very unlikely that this rescue block will run, but if another process somehow sneaks in a row creation
              # right before the above create operation can run, just return an LockError.
              raise Hyacinth::Exceptions::LockError, "Lock on #{key} is currently held by another process."
            end
          end
          LockObject.new(database_entry_lock, @lock_timeout)
        end

        # Attempts to establish a lock on the given key and then yields to a block. The lock is are automatically unlocked when the block is completed.
        # :yields: lock_object [Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject] A lock object that can have its lock extended if necessary,
        # or nil if a nil key is given.
        def with_lock(key)
          with_multilock(Array.wrap(key)) do |lock_objects|
            yield lock_objects[key]
          end
        end

        # Attempts to establish locks on the given keys and then yields to a block. All locks are automatically unlocked when the block is completed.
        # @param keys An array of keys to lock on.
        # :yields: lock_objects [Hash] A hash that maps lock keys to lock objects (Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject).
        #                              Each lock object has an #extend_lock method that can be called to extend that lock by the application-wide lock timeout.
        def with_multilock(keys)
          # We're going to remove nil values from the passed in keys, since we can't lock on nil.
          # Cast the passed-in object to an array so we can handle a Set.
          # Make a copy of the keys array so we don't modify the passed-in object.
          keys = keys.nil? ? [] : keys.to_a.dup.compact

          # If no keys have been passed in, just yield and return.
          # This simplifies things for any calling code that wants to pass in a
          # variable number of dependent lock-needing resources when there's a
          # possibility that certain situations may not require any locks at all.
          if keys.blank?
            yield Hash.new
            return
          end

          raise ArgumentError, "Duplicate object id found in given keys: #{keys.join(', ')}" if keys.uniq.length != keys.length
          lock_objects = {}
          already_locked_ids = []

          keys.each do |key|
            lock_objects[key] = lock(key)
          rescue Hyacinth::Exceptions::LockError
            already_locked_ids << key
          end

          if already_locked_ids.present?
            # unlock any locks we just established
            lock_objects.each do |_key, lock_object|
              lock_object.unlock
            end
            # and then raise an exception
            raise Hyacinth::Exceptions::LockError, already_locked_ids.length == 1 ?
              "Lock on #{already_locked_ids.first} is currently held by another process." :
              "Locks on #{already_locked_ids.join(', ')} are currently held by other processes."
          end

          # TODO: Write a test to ensure that the locks are unlocked if the given block raises an exception.
          begin
            # yield lock_objects so that given block can extend the locks if necessary
            yield lock_objects
          ensure
            # Unlock lock_objects now that we're done with them
            lock_objects.each do |_key, lock_object|
              lock_object.unlock
            end
          end
        end

        # Removes the lock for the given key. Generally you don't want to use this method. It's
        # just here in cases when you need to manually remove a lock that was obtained by another
        # process. Instead of calling this method, it's generally better to instead use the
        # LockObject returned by #lock (i.e. lock_object.unlock).
        def unlock!(key)
          ::DatabaseEntryLock.destroy_by(lock_key: key)
        end

        # TODO: Add tests for this class
        class LockObject
          attr_reader :database_entry_lock
          attr_reader :lock_timeout

          def initialize(database_entry_lock, lock_timeout)
            @database_entry_lock = database_entry_lock
            @lock_timeout = lock_timeout
            @locked = true
          end

          def extend_lock
            raise Hyacinth::Exceptions::LockError, 'Cannot call #extend_lock because #unlock has already been called.' unless @locked
            @database_entry_lock.update!(expires_at: DateTime.current + @lock_timeout.seconds)
          end

          # Extends the lock if it will expire in less than the given duration.
          # @param [Integer or ActiveSupport::Duration] duration
          def extend_lock_if_expires_in_less_than(duration)
            extend_lock if duration > remaining_lock_time
          end

          def remaining_lock_time
            (@database_entry_lock.expires_at - DateTime.current).to_f
          end

          def unlock
            @database_entry_lock.delete
            @locked = false
          end
        end
      end
    end
  end
end
