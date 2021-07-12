# frozen_string_literal: true

module DigitalObjectConcerns
  module LockBehavior
    extend ActiveSupport::Concern
    def lock
      return if self.new_record?
      self.latest_lock_object = Hyacinth::Config.lock_adapter.lock(self.uid)
    end

    def unlock
      self.latest_lock_object&.unlock
    end

    def unlock!
      @latest_lock_object = Hyacinth::Config.lock_adapter.unlock!(self.uid)
    end

    def extend_lock
      @latest_lock_object&.extend_lock
    end

    def reject_optimistic_lock_token_if_stale!
      # Compare this object's optimistic lock token with the value currently in the database
      # Note: pluck does not lead to ActiveRecord object instantiation, so we don't need to worry
      # about ongoing object locks.
      return if self.new_record?
      return if self.optimistic_lock_token == DigitalObject.where(id: self.id).pluck(:optimistic_lock_token).first
      self.errors.add(:optimistic_lock_token, "This digital object has been updated by another process and your data is stale. Please reload and apply your changes again.")
      throw(:abort)
    end
  end
end
