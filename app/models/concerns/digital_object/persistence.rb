module DigitalObject::Persistence
  extend ActiveSupport::Concern

  def save
    before_save

    return false unless self.valid?

    creating_new_record = self.new_record?

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
    update_index

    # If we got here, then everything is good. Run after-create and before_publish logic
    run_after_create_logic if creating_new_record
    publish if @publish_after_save

    @errors.blank?
  end

  def before_save
    # TODO: rewrite with ActiveRecord::Callbacks
    # To be overridden by subclasses

    mint_and_store_doi(Hyacinth::Ezid::Doi::IDENTIFIER_STATUS[:reserved]) if @mint_reserved_doi_before_save
  end

  def persist_to_stores
    DigitalObjectRecord.transaction do
      if self.new_record?
        @fedora_object ||= create_fedora_object
        @db_record.pid = @fedora_object.pid
      else
        # Within the established transaction, lock on this object's row.
        # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
        # Remember: "lock!" also reloads object data from the db, so perform all @db_record modifications AFTER this call.
        @db_record.lock!
      end

      # Add pid to identifiers if not present
      @identifiers << pid unless @identifiers.include?(pid)

      run_post_validation_pre_save_logic

      save_data_to_fedora

      @db_record.save! # Save timestamps + updates to modifed_by, etc.

      begin
        # Retry after Fedora timeouts / unreachable host
        Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
          @fedora_object.save(update_index: false)
        end
      rescue Rubydora::FedoraInvalidRequest, RestClient::RequestTimeout,
             RestClient::Unauthorized, Errno::EHOSTUNREACH => e
        # Rubydora::FedoraInvalidRequest is raised when we run into unexpected Fedora issues
        @errors.add(:fedora_error, e.message)
        raise ActiveRecord::Rollback # Force rollback (Note: This error won't be passed upward by the transaction.)
      end
    end
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
      parent_obj = DigitalObject::Base.find(digital_obj_pid)
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
              remove_parent_digital_object(obj)
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
