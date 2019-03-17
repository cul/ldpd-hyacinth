module DigitalObjectConcerns::PreserveBehavior
  extend ActiveSupport::Concern

  # Persists this object to preservation storage.
  # Note: This method calls save on the digital object because successful
  # preserving modifies the object's preservation timestamps.
  # @param publishing_user [User] user who is initiating this publish operation.
  def preserve
    success, errors = Hyacinth.config.preservation_persistence.persist(self)
    if success
      update_preservation_timestamps
      self.save # Save digital object because we just updated preservation timestamps
    else
      self.errors.add(:preservation, "The following errors occurred during preservation: #{errors.join("\n")}")
    end
  end

  # Updated preservation timestamps (first_persisted_to_preservation_at and persisted_to_preservation_at)
  def update_preservation_timestamps
    current_datetime = DateTime.now
    # If this is the first time we've persisted this item to preservation, make a note of the date/time.
    self.first_persisted_to_preservation_at = current_datetime unless self.first_persisted_to_preservation_at.present?
    # Make a note of the latest preservation time.
    self.persisted_to_preservation_at = current_datetime
  end
end
