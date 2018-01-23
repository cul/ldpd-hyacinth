module DigitalObject::DigitalObjectRecord
  extend ActiveSupport::Concern

  ##################################
  # DB object data loading methods #
  ##################################

  def load_data_from_db_record!
    @created_by = @db_record.created_by
    @updated_by = @db_record.updated_by
    @first_published_at = @db_record.first_published_at
  end

  ##################################
  # DB object data writing methods #
  ##################################

  def set_created_and_updated_data_from_db_record
    if self.new_record?
      @db_record.created_by = @created_by
      @db_record.created_at = @created_at
    end

    @db_record.updated_by = @updated_by
    @db_record.updated_at = Time.now # Always setting this manually just in case there aren't any other changes to @db_record (becase otherwise the record's updated_at time wouldn't change automatically)
  end

  def set_first_published_at
    # Save _first_published_at date, if we are going to attempt to publish to
    # primary publish target. Otherwise, convert date if it is a String
    if @first_published_at.blank? && publishing_to_primary_publish_target?
      @first_published_at = Time.current
    elsif @first_published_at.is_a?(String)
      begin
        @first_published_at = Time.iso8601(@first_published_at)
      rescue ArgumentError => e
        @errors.add(:first_published_at, 'first_published_at date invalid. Date must be in valid ISO8601 format.')
      end
    end

    # Setting string to field will result in saving nil.
    @db_record.first_published_at = @first_published_at if @first_published_at.is_a?(Time)
  end
end
