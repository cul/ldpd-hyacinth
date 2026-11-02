module DigitalObject::DigitalObjectRecord
  extend ActiveSupport::Concern

  ##################################
  # DB object data loading methods #
  ##################################

  def load_data_from_db_record!
    @created_by = @db_record.created_by
    @updated_by = @db_record.updated_by
    @first_published_at = @db_record.first_published_at
    # For perform_derivative_processing, if a db record for this resource has been previously saved,
    # use that value. Otherwise just use default value set by the DigitalObject::Base or its subclass.
    @perform_derivative_processing = @db_record.new_record? ? @perform_derivative_processing : @db_record.perform_derivative_processing
    @publish_target_string_keys = self.db_record.publish_targets.map { |publish_target| publish_target.string_key }
  end

  ##################################
  # DB object data writing methods #
  ##################################

  def save_data_to_db_record
    if self.new_record?
      @db_record.created_by = @created_by
      @db_record.created_at = @created_at
    end

    @db_record.updated_by = @updated_by
    @db_record.updated_at = Time.now # Always setting this manually just in case there aren't any other changes to @db_record (becase otherwise the record's updated_at time wouldn't change automatically)

    found_publish_targets = PublishTarget.where(string_key: @publish_target_string_keys)
    missing_publish_targets = @publish_target_string_keys - found_publish_targets.map(&:string_key)
    raise Hyacinth::Exceptions::PublishTargetNotFoundError, "Could not find publish targets: #{missing_publish_targets.join(', ')}" if missing_publish_targets.present?

    self.db_record.publish_targets = found_publish_targets
  end

  def set_perform_derivative_processing
    @db_record.perform_derivative_processing = @perform_derivative_processing
  end

  def set_first_published_at
    # Convert date if it is a String (first_published_at is otherwise set after a successful publish)
    if @first_published_at.is_a?(String)
      begin
        @first_published_at = Time.iso8601(@first_published_at)
      rescue ArgumentError
        @errors.add(:first_published_at, 'first_published_at date invalid. Date must be in valid ISO8601 format.')
      end
    end

    # Setting string to field will result in saving nil.
    @db_record.first_published_at = @first_published_at if @first_published_at.is_a?(Time)
  end
end
