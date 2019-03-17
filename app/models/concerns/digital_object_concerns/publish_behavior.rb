module DigitalObjectConcerns::PublishBehavior
  extend ActiveSupport::Concern

  # Sends publish and unpublish requests to relevant publish targets.
  # Note: This method calls save on the digital object because successful
  # publishing/unpublishing modifies the object's publish_target_entries.
  # @param publishing_user [User] user who is initiating this publish operation.
  def publish(publishing_user = nil)
    # Try to publish to or unpublish from all specified publish targets,
    # regardless of whether any operations fails. We'll notify the user if
    # things fail by adding errors to the errors object.

    # Minimize the number of SQL queries by retrieving all referenced publish targets in one operation
    string_keys_to_publish_targets = PublishTarget.where(
      string_key: (self.publish_to + self.unpublish_from)
    ).map{ |publish_target| [publish_target.string_key, publish_target] }.to_h

    # Do deep copy of current (frozen) publish_entries
    new_publish_entries = self.publish_entries.dup

    # Use same published_at time for all publish operations in this batch
    current_datetime = DateTime.now

    publish_errors = []
    unpublish_errors = []

    if publish_to.present? && self.first_published_at.blank?
      # If this is the first time we're publishing this item, make a note of the date/time.
      self.first_published_at = current_datetime
    end

    # Handle publish_to
    self.publish_to.each do |publish_target_string_key|
      result, errors = string_keys_to_publish_targets[publish_target_string_key].publish(self)
      if result
        self.publish_to.delete(publish_target_string_key)
        new_publish_entries[publish_target_string_key] = Hyacinth::PublishEntry.new(published_at: current_datetime, published_by: publishing_user)
      else
        publish_errors << "Unable to publish to publish target #{publish_target_string_key} due to the following errors: " + errors.join("\n")
      end
    end

    # Handle publish_to
    self.publish_to.each do |publish_target_string_key|
      result, errors = string_keys_to_publish_targets[publish_target_string_key].unpublish(self)
      if result
        self.unpublish_from.delete(publish_target_string_key)
        new_publish_entries.delete(publish_target_string_key)
      else
        unpublish_errors << "Unable to unpublish from publish target #{publish_target_string_key} due to the following errors: " + errors.join("\n")
      end
    end

    # Since our publish entries changed as a result of the publish, we need to
    # re-save this digital object.
    self.save

    # AFTER the save (because save clears out errors), add any publish or
    # unpublish errors to this digital object's errors object.
    publish_errors.each do |publish_error|
      self.errors.add(:publish, publish_error)
    end
    unpublish_errors.each do |publish_error|
      self.errors.add(:unpublish, publish_error)
    end

    # Return true if there are errors. Otherwise return false.
    self.errors.blank?
  end

end
