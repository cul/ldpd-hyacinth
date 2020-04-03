# frozen_string_literal: true

module DigitalObjectConcerns
  module DestroyBehavior
    extend ActiveSupport::Concern

    # This method is like the other #destroy method, but it raises an error if the destruction fails.
    def destroy!(opts = {})
      return true if destroy(opts)
      raise Hyacinth::Exceptions::DeletionError, "DigitalObject may not have been fully destroyed. Errors: #{self.errors.full_messages}"
    end

    # Marks this object as deleted and runs destroy callbacks.
    # @param opts [Hash] A hash of options. Options include:
    #             :lock [boolean] Whether or not to lock on this object during destroy.
    #                             You generally want this to be true, unless you're establishing a lock on
    #                             this object outside of the save call for another reason. Defaults to true.
    #             :user [User] User who is performing the destroy operation.
    def destroy(opts = {})
      # run_callbacks returns the result of its block
      run_callbacks :destroy do
        destroy_impl(opts)
      end
    end

    # Marks this object as active.
    # @param opts [Hash] A hash of options. Options include:
    #             :lock [boolean] Whether or not to lock on this object during undestroy.
    #                             You generally want this to be true, unless you're establishing a lock on
    #                             this object outside of the save call for another reason. Defaults to true.
    #             :user [User] User who is performing the undestroy operation.
    def undestroy(opts = {})
      # Always lock during undestroy unless opts[:lock] explicitly tells us not to.
      Hyacinth::Config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |_lock_object|
        self.state = Hyacinth::DigitalObject::State::ACTIVE
        self.updated_by = opts[:user] if opts[:user]
        self.updated_at = DateTime.current
        write_to_metadata_storage
      end
      self.errors.blank?
    end

    private

      def destroy_impl(opts = {})
        # Always lock during destroy unless opts[:lock] explicitly tells us not to.
        # In the line below, self.uid will be nil for new objects and this lock
        # line will simply yield without locking on anything, which is fine.
        Hyacinth::Config.lock_adapter.with_lock(opts.fetch(:lock, true) ? self.uid : nil) do |_lock_object|
          self.state = Hyacinth::DigitalObject::State::DELETED
          self.updated_by = opts[:user] if opts[:user]
          self.updated_at = DateTime.current
          write_to_metadata_storage
        end
        self.errors.blank?
      end
  end
end
