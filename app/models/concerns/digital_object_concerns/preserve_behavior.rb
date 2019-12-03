# frozen_string_literal: true

module DigitalObjectConcerns
  module PreserveBehavior
    extend ActiveSupport::Concern

    # Preserves this object to all environment-enabled preservation targets.
    def preserve
      Hyacinth.config.lock_adapter.with_lock(self.uid) do
        current_datetime = DateTime.current
        before_preserve_copy = self.deep_copy
        begin
          self.mint_reserved_doi_if_doi_blank
          update_preservation_timestamps(current_datetime)
          preservation_result, errors = Hyacinth.config.preservation_persistence.preserve(self)
          unless preservation_result
            self.errors.add(:preservation, "An error occured during preservation. See error log for details.")
            Rails.logger.error("Failed to preserve #{self.uid} due to the following errors: #{errors.join(', ')}")
          end
          @preserve = false # switch off preserve flag because preservation is complete
        rescue StandardError => e
          # We don't necessarily want to revert the entire object
          # to the pre-preservation-attempt state because we may not know exactly
          # why preservation failed (or whether an incomplete preservation occured),
          # so the best way to handle preservation failure is to troubleshoot
          # the issue and then re-preserve properly.
          # Also, there's a pretty good chance that if preservation fails,
          # we won't be able to run preservation again in an attempt to
          # preserve the before_preserve_copy DigitalObject state.

          # The only thing we'll potentially revert is the first_preserved_at time,
          # in case this is the first time we're preserving. It's fine to keep
          # and DOI that we minted.
          self.first_preserved_at = before_preserve_copy.first_preserved_at

          raise e # pass along the exception
        end
      end

      self.errors.blank?
    end

    def update_preservation_timestamps(current_datetime)
      self.preserved_at = current_datetime
      self.first_preserved_at = current_datetime if self.first_preserved_at.blank?
    end
  end
end
