module DigitalObject::DigitalObjectRecord
  extend ActiveSupport::Concern

  ##################################
  # DB object data loading methods #
  ##################################

  def load_created_and_updated_data_from_db_record!
    @created_by = @db_record.created_by
    @updated_by = @db_record.updated_by
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

end
