require 'fileutils'
module DigitalObject::Persistence
  extend ActiveSupport::Concern

  def save(manual_commit_to_solr = true)
    if @publish_after_save && ! HYACINTH[:publish_enabled]
      @errors.add(:publish, 'Digital Objects cannot be published right now because Hyacinth publishing has been disabled by an administrator. You can still save though.')
      return false
    end

    before_save

    return false unless self.valid?

    creating_new_record = self.new_record? # save creation info because after persist_to_stores is called, new_record? will return false

    persist_to_stores

    # If we saved this object successfully in DB and Fedora, perform additional logic below, including:
    # - Updating the struct data of the parent objects (adding new children and removing old children)
    # - Updating the solr index
    if @errors.present?
      return false
    else
      persist_parent_changes
    end

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
    mint_and_store_doi(Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:draft]) if @mint_reserved_doi_before_save || @publish_after_save
  end

  def persist_to_stores
    @fedora_object ||= create_fedora_object if self.new_record? # do this outside of transaction because it also requires its own transaction

    DigitalObjectRecord.transaction do
      if self.new_record?
        @db_record.pid = @fedora_object.pid
      else
        # Within the established transaction, lock on this object's row.
        # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
        # Remember: "lock!" also reloads object data from the db, so perform all @db_record modifications AFTER this call.
        @db_record.lock!
      end

      if @db_record.uuid.blank?
        @db_record.uuid = SecureRandom.uuid
      end

      add_pid_and_uuid_identifiers

      begin
        run_post_validation_pre_save_logic
      rescue Hyacinth::Exceptions::ZeroByteFileError => e
        @errors.add(:import_file, e.message)
        raise ActiveRecord::Rollback # Force rollback (Note: This error won't be passed upward by the transaction.)
      end

      set_data_to_sources

      @db_record.save! # Save timestamps + updates to modifed_by, etc.

      begin
        # Retry after Fedora timeouts / unreachable host
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

      # Write to data file
      FileUtils.mkdir_p(File.dirname(@db_record.data_file_path))
      IO.write(@db_record.data_file_path, self.as_hyacinth_3_json.to_json)
    end
  end

  def add_pid_and_uuid_identifiers
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

          return true
        else
          if @parent_digital_object_pids.present?
            # If present, convert this DigitalObject's parent membership relationships to obsolete parent relationships (for future auditing/troubleshooting purposes)
            @parent_digital_object_pids.each do |parent_digital_object_pid|
              obj = DigitalObject::Base.find(parent_digital_object_pid)
              remove_parent_digital_object_by_pid(obj.pid)
            end
          end

          return save
        end
      else
        Hyacinth::Utils::Logger.logger.error "Tried to delete Hyacinth record with pid #{pid}, but record was not valid. Errors: #{errors.messages.inspect}"
      end
    end

    false
  end

  # Note: purge method is not currently implemented.  If implemented some day, this would completely delete all traces of an object from Fedora.
  def purge
    raise 'Purge is not currently supported.  Use the destroy method instead, which marks an object as deleted.'
  end

  module ClassMethods
  end
end
