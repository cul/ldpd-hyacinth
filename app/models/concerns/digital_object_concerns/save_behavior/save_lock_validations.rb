# frozen_string_literal: true

module DigitalObjectConcerns
  module SaveBehavior

    # Validations that are meant to be run within the context of
    # an object lock during a save operation.
    module SaveLockValidations
      extend ActiveSupport::Concern

      def run_save_lock_validations(allow_structured_child_addition_or_removal)
        if self.persisted?
          persisted_copy = DigitalObject::Base.find(self.uid)

          # If the persisted version has a different optimistic_lock_token than
          # this instance, raise an error because we're out of sync and don't want
          # to overwrite recent changes made by another process.
          validate_optimistic_lock_token(persisted_copy.optimistic_lock_token)

          # In order to keep bidirectional parent-child references from getting out of sync,
          # we only allow addition or removal of uids in structured_children when explicitly
          # granted (via the allow_structured_child_addition_or_removal opt). Rearrangement
          # (without new uid addition or removal) is always fine, and does not require the
          # explicit opt. The method below raises an exception if the previous set of
          # structured children does not contain the same objects as the current set.
          validate_structured_child_addition_or_removal(
            allow_structured_child_addition_or_removal,
            persisted_copy.flat_child_uid_set
          )
        end

        self.errors.blank?
      end

      # Checks to see if the optimistic_lock_token for this object is the same as the expected token.
      # @return [Boolean] true if the expected token is present
      def validate_optimistic_lock_token(expected_optimistic_lock_token)
        return true if self.optimistic_lock_token == expected_optimistic_lock_token
        self.errors.add(:stale_data, "This digital object has been updated by another process and your data is stale. Please reload and apply your changes again.")
        false
      end

      def validate_structured_child_addition_or_removal(allow_structured_child_addition_or_removal, previous_state_flat_child_uid_set)
        # If changes are allowed, return true regardless of whether changes were made.
        return true if allow_structured_child_addition_or_removal

        # If changes aren't allowed, see if any children were added or removed.
        return true if self.flat_child_uid_set == previous_state_flat_child_uid_set

        self.errors.add(
          :structured_children,
          'Not allowed to add or remove structured children in this context. '\
          'Children may have been modified by another process. '\
          'Current attempt would have potentially led to an out-of-sync parent-child situation.'
        )
        false
      end

    end
  end
end
