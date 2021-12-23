# frozen_string_literal: true

module DigitalObjectConcerns
  module PreserveBehavior
    extend ActiveSupport::Concern

    # Preserves this object to all environment-enabled preservation targets.
    def preserve
      # No one should be preserving an object that has errors
      return false if self.errors.present?

      Hyacinth::Config.lock_adapter.with_lock("#{self.uid}-preserve") do |_lock_object|
        ensure_doi!
        break if self.errors.present?

        preservation_result, errors = Hyacinth::Config.preservation_persistence.preserve(self)

        unless preservation_result
          self.errors.add(:preservation, "Failed to preserve #{self.uid} due to the following errors: #{errors.join(', ')}")
          break
        end

        update_preservation_timestamps(DateTime.current)
        self.save
      end

      self.errors.blank?
    end

    def update_preservation_timestamps(datetime)
      self.first_preserved_at = datetime if self.first_preserved_at.blank?
      self.preserved_at = datetime
    end
  end
end
