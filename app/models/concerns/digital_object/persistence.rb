require 'fileutils'
module DigitalObject::Persistence
  extend ActiveSupport::Concern

  def save(manual_commit_to_solr = true)
    if @publish_after_save && ! HYACINTH[:publish_enabled]
      @errors.add(:publish, 'Digital Objects cannot be published right now because Hyacinth publishing has been disabled by an administrator. You can still save though.')
      return false
    end

    before_save

    return false unless @errors.blank? && self.valid?

    creating_new_record = self.new_record? # save creation info because after persist_to_stores is called, new_record? will return false

    persist_to_stores

    # If we saved this object successfully in DB and Fedora, perform additional logic below, including:
    # - Updating the struct data of the parent objects (adding new children and removing old children)
    # - Updating the solr index
    return false if @errors.present?

    persist_parent_changes

    return false if @errors.present?

    # Update the solr index
    update_index(manual_commit_to_solr)

    # If we got here, then everything is good. Run after-create and before_publish logic
    run_after_create_logic if creating_new_record
    run_after_save_logic

    publish if @publish_after_save

    @errors.blank?
  end

  def before_save
    # TODO: rewrite with ActiveRecord::Callbacks
    # To be overridden by subclasses
    if @mint_reserved_doi_before_save || (@publish_after_save && self.doi.blank?)
      mint_and_store_doi(Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:draft])
    end
  rescue Hyacinth::Exceptions::DataciteErrorResponse, Hyacinth::Exceptions::DataciteConnectionError, Hyacinth::Exceptions::DoiExists => e
    @errors.add(:datacite, e.message)
  end

  def persist_to_stores
    if self.new_record?
      # Right now, a corresponding Fedora Object is required the first time any Hyacinth object is saved.
      # One day, when Hyacinth is more decoupled from Fedora, this won't be necessary.
      @fedora_object ||= create_fedora_object
      @db_record.pid = @fedora_object.pid
    end

    DigitalObjectRecord.transaction do
      # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction).
      # This prevents two different users from trying to edit the same Hyacinth record at the same time.
      # Remember: "lock!" also reloads object data from the db, so make sure to save the @db_record before this
      # if you modify it in any way.
      # We do NOT lock for new records, since there's no risk of simultaneous edit.  New records are also slow
      # to save for the first time becuase they sometimes involve a large file upload, and the db lock might time out
      # so it's good that we don't need to lock in that scenario.
      @db_record.lock! unless self.new_record?

      assign_pid_and_uuid_to_identifiers

      begin
        run_post_validation_pre_save_logic # Reminder: This method processes file imports
      rescue Hyacinth::Exceptions::ZeroByteFileError => e
        @errors.add(:import_file, e.message)
        raise ActiveRecord::Rollback # Force rollback (Note: This error won't be passed upward by the transaction.)
      end

      set_data_to_sources

      @db_record.save! # Save timestamps + updates to modifed_by, etc.

      # Write to digital_object_data file
      # NOTE: This file is being written to, but isn't being read by any processes right now.  It's something that
      # we will potentially use more later on when we decouple Hyacinth from Fedora.
      digital_object_data_file_path = Hyacinth::Utils::PathUtils.data_file_path_for_uuid(self.uuid)
      FileUtils.mkdir_p(File.dirname(digital_object_data_file_path))
      IO.write(digital_object_data_file_path, self.to_json)

      begin
        # This block is retriable just in case Fedora times out or is briefly unreachable
        Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
          @fedora_object.save(update_index: false)
        end
      rescue Rubydora::FedoraInvalidRequest, RestClient::RequestTimeout,
             RestClient::NotFound, RestClient::Unauthorized, Errno::EHOSTUNREACH => e
        # Rubydora::FedoraInvalidRequest is raised when we run into unexpected Fedora issues
        @errors.add(:fedora_error, e.message)
        Rails.logger.error("Received error from Fedora while attempting to save #{@fedora_object.pid}: #{e.message}")
        raise ActiveRecord::Rollback # Force rollback (Note: This error won't be passed upward by the transaction.)
      end
    end
  end

  def assign_pid_and_uuid_to_identifiers
    # Add pid to identifiers if not present
    @identifiers << @db_record.pid unless @identifiers.include?(@db_record.pid)

    # Add uuid to identifiers if not present
    @identifiers << @db_record.uuid unless @identifiers.include?(@db_record.uuid)
  end

  def persist_parent_changes
    return unless parent_digital_object_pids_changed?

    removed_parents = parent_digital_object_pids_was - parent_digital_object_pids
    new_parents = parent_digital_object_pids - parent_digital_object_pids_was

    # Parent changes MUST be saved after Fedora object changes because they rely on the state of the live Fedora Object.
    # Update all removed parents AND new parents so they have the latest member changes.

    # If Fedora's Resource Index is set to update IMMEDIATELY
    # after object modification, we can use the lines below,
    # simply re-saving each affected parent.  If not, this is unsafe to use.
    # Resource Update flush settings must be configured in fedora.fcfg.

    (removed_parents + new_parents).each do |digital_obj_pid|
      parent_obj = DigitalObject::Base.find_by_pid(digital_obj_pid)

      # Note: At this time, it's possible that the parent object exists in Fedora,
      # but not Hyacinth. We'll skip saving these objects because Hyacinth doesn't
      # manage them. Since we only ever add parent pids to objects after verifying
      # that they exist in either Hyacinth OR Fedora, this skipping action is safe.
      next if parent_obj.nil?

      unless parent_obj.save
        @errors.add(:parent_digital_objects, parent_obj.errors.full_messages.join(', '))
      end
    end
  end

  # By default, marks a record as deleted, but doesn't completely purge it from the system.
  # Pass true for the purge param to completely eradicate this record.
  # Pass true for the force param to eradicate the record even if it doesn't pass
  # validation. This will delete a record without updating other records that reference it (i.e. child records).
  # NOTE: This method does NOT delete files on the filesystem.
  def destroy(purge = false, force = false)
    result = false
    @db_record.with_lock do
      # Set state of 'D' for this object, which means "deleted" in Fedora
      self.state = 'D'

      if valid? || force
        # Unpublish items from active publish targets.
        unpublish_all

        if purge
          # We're going to delete everything associated with this record

          # Delete from Solr
          Hyacinth::Utils::SolrUtils.solr.delete_by_query "pid:#{Hyacinth::Utils::SolrUtils.solr_escape(pid)}"
          Hyacinth::Utils::SolrUtils.solr.commit

          # Delete from Fedora
          Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
            @fedora_object.delete
          end

          # Delete db record
          @db_record.destroy

          result = true
        else
          if @parent_digital_object_pids.present?
            # If present, convert this DigitalObject's parent membership relationships to obsolete parent relationships (for future auditing/troubleshooting purposes)
            @parent_digital_object_pids.each do |parent_digital_object_pid|
              obj = DigitalObject::Base.find(parent_digital_object_pid)
              remove_parent_digital_object_by_pid(obj.pid)
            end
          end

          result = save
        end
      else
        Hyacinth::Utils::Logger.logger.error "Tried to delete Hyacinth record with pid #{pid}, but record was not valid. Errors: #{errors.messages.inspect}"
      end
    end

    result
  end

  # Note: purge method is not currently implemented.  If implemented some day, this would completely delete all traces of an object from Fedora.
  def purge
    raise 'Purge is not currently supported.  Use the destroy method instead, which marks an object as deleted.'
  end

  module ClassMethods
  end
end
