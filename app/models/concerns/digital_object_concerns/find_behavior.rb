# frozen_string_literal: true

module DigitalObjectConcerns::FindBehavior
  extend ActiveSupport::Concern

  module ClassMethods
    # Check whether an object with the given uid exists
    # @param uid [String] uid to search for
    def exists?(uid)
      DigitalObjectRecord.exists?(uid: uid)
    end

    def find(uid)
      # Important note: We don't want to do a lock when finding. That would
      # mess up other code that assumes no locking during find operations.
      # The optimistic_lock_token exists so that we don't need to lock on find
      # operations. We can find any time we want, but when we save we'll be
      # notified if another person saved and made our object instance stale.
      digital_object_record = DigitalObjectRecord.find_by(uid: uid)
      raise Hyacinth::Exceptions::NotFound, "Could not find DigtalObject with uid: #{uid}" if digital_object_record.nil?
      json_var = JSON.parse(Hyacinth::Config.metadata_storage.read(digital_object_record.metadata_location_uri))
      from_serialized_form(digital_object_record, json_var)
    end
  end
end
