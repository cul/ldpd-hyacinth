class DigitalObject::Base

  include ActiveModel::Dirty
  include DigitalObject::IndexAndSearch
  include DigitalObject::Validation
  include DigitalObject::Fedora
  include DigitalObject::DigitalObjectRecord
  include DigitalObject::DynamicField
  include DigitalObject::XmlDatastreamRendering

  NUM_FEDORA_RETRY_ATTEMPTS = 3
  DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS = 5.seconds

  # For ActiveModel::Dirty
  define_attribute_methods :parent_digital_object_pids, :obsolete_parent_digital_object_pids, :ordered_child_digital_object_pids

  attr_accessor :projects, :publish_targets, :created_by, :updated_by, :state, :struct_data, :dc_type, :ordered_child_digital_object_pids
  attr_reader :errors, :fedora_object, :parent_digital_object_pids, :updated_at, :created_at, :dynamic_field_data

  VALID_DC_TYPES = [] # There are no valid dc types for DigitalObject::Base

  def initialize(digital_object_record=::DigitalObjectRecord.new, fedora_obj=nil)
    raise 'The DigitalObject::Base class cannot be instantiated.  You can only instantiate subclasses like DigitalObject::Item' if self.class == DigitalObject
    @db_record = digital_object_record
    @fedora_object = fedora_obj

    if self.new_record?
      @projects = []
      @publish_targets = []
      @parent_digital_object_pids = []
      @obsolete_parent_digital_object_pids = []
      @ordered_child_digital_object_pids = []
      @dynamic_field_data = {}
      @state = 'A'
    else
      # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
      @db_record.with_lock do # with_lock creates a transaction and locks on the called object's row
        load_created_and_updated_data_from_db_record!
        load_parent_digital_object_pid_relationships_from_fedora_object!
        load_state_from_fedora_object!
        load_dc_type_from_fedora_object!
        load_project_and_publisher_relationships_from_fedora_object!
        load_fedora_hyacinth_ds_data_from_fedora_object!
      end
    end

    @errors = ActiveModel::Errors.new(self)
  end

  # Returns the primary title
  def get_title
    title = ''
    if @dynamic_field_data['title'] && @dynamic_field_data['title'].first && @dynamic_field_data['title'].first['title_non_sort_portion']
      title += @dynamic_field_data['title'].first['title_non_sort_portion'] + ' '
    end
    title += self.get_sort_title
    return title
  end

  # Returns the sort portion of the primary title
  def get_sort_title
    sort_title = '[No Title]'
    if @dynamic_field_data['title'] && @dynamic_field_data['title'].first && @dynamic_field_data['title'].first['title_sort_portion']
      sort_title = @dynamic_field_data['title'].first['title_sort_portion']
    end
    return sort_title
  end

  # Sets the title
  def set_title(non_sort_portion, sort_portion)
    @dynamic_field_data['title'] = [
      {
        'title_non_sort_portion' => non_sort_portion,
        'title_sort_portion' => sort_portion
      }
    ]
  end

  def add_parent_digital_object(parent_digital_object)
    new_parent_digital_object_pid = parent_digital_object.pid

    unless @parent_digital_object_pids.include?(new_parent_digital_object_pid)
      parent_digital_object_pids_will_change!
      @parent_digital_object_pids << new_parent_digital_object_pid
    end

    if @obsolete_parent_digital_object_pids.include?(new_parent_digital_object_pid)
      obsolete_parent_digital_object_pids_will_change!
      @obsolete_parent_digital_object_pids.delete(new_parent_digital_object_pid)
    end
  end

  def remove_parent_digital_object(parent_digital_object)
    parent_digital_object_pid = parent_digital_object.pid
    if @parent_digital_object_pids.include?(parent_digital_object_pid)
      parent_digital_object_pids_will_change!
      obsolete_parent_digital_object_pids_will_change!
      deleted_pid = @parent_digital_object_pids.delete(parent_digital_object_pid)
      @obsolete_parent_digital_object_pids << deleted_pid unless @obsolete_parent_digital_object_pids.include?(deleted_pid)
    end
  end

  # This method is only required for when the ResourceIndex doesn't have immediate updates turned on
  def remove_ordered_child_digital_object_pid(digital_object_pid)
    if @ordered_child_digital_object_pids.include?(digital_object_pid)
      @ordered_child_digital_object_pids.delete(digital_object_pid)
    end
  end

  # This method is only required for when the ResourceIndex doesn't have immediate updates turned on
  def add_ordered_child_digital_object_pid(digital_object_pid)
    unless @ordered_child_digital_object_pids.include?(digital_object_pid)
      @ordered_child_digital_object_pids << digital_object_pid
      puts 'added ---> ' +  digital_object_pid.to_s
    end
  end

  # Marks a record as deletedm but doesn't completely purge it from the system
  def destroy

    @db_record.with_lock do
      # Set state of 'D' for this object, which means "deleted" in Fedora
      self.state = 'D'


      if valid?
        if @parent_digital_object_pids.present?
          # If present, convert this DigitalObject's parent membership relationships to obsolete parent relationships (for future auditing/troubleshooting purposes)
          @parent_digital_object_pids.each do |parent_digital_object_pid|
            obj = DigitalObject::Base.find(parent_digital_object_pid)
            self.remove_parent_digital_object(obj)
          end
        end

        return self.save
      end
    end
  end

  # Note: purge method is not currently implemented.  If implemented some day, this would completely delete all traces of an object from Fedora.
  def purge
    raise 'Purge is not currently supported.  Use the destroy method instead, which marks an object as deleted.'
  end

  def require_subclass_override!; raise 'This method must be overridden by a subclass'; end

  # Get a new, unsaved, appropriately-configured instance of the right tyoe of Fedora object a DigitalObject subclass
  def get_new_fedora_object; require_subclass_override!; end

  def new_record?
    return @db_record.new_record?
  end

  # Getters

  def pid
    return self.new_record? ? nil : @fedora_object.pid
  end

  # Find/Save/Validate

  def self.find(pid)
    digital_object_record = ::DigitalObjectRecord.find_by(pid: pid)

    if digital_object_record.blank?
      raise Hyacinth::DigitalObjectNotFoundError.new("Couldn't find DigitalObject with pid #{pid}")
    end

    # Handle Fedora timeouts / unreachable host.  Try up to 3 times.
    fobj = nil
    NUM_FEDORA_RETRY_ATTEMPTS.times { |i|
      begin
        fobj = ActiveFedora::Base.find(pid)
        break
      rescue RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH => e
        remaining_attempts = (NUM_FEDORA_RETRY_ATTEMPTS-1) - i
        if remaining_attempts == 0
          raise e
        else
          Rails.logger.error "Error: Could not connect to fedora. (#{e.class.to_s + ': ' + e.message}).  Will retry #{remaining_attempts} more #{remaining_attempts == 1 ? 'time' : 'times'} (after a #{DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS} second delay)."
          sleep DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS
        end
      end
    }

    class_to_instantiate = DigitalObject::Base.get_class_for_fedora_object(fobj)
    return class_to_instantiate.new(digital_object_record, fobj)
  end

  # Returns the DigitalObject::Something class for the given Fedora object.
  # Only handles types expected by Hyacinth
  def self.get_class_for_fedora_object(fobj)
    # This seems weird, but when comparing against classes, you do "case object" instead of "case object.class", but still compare against classes.
    # This is because of how === comparison works on classes
    # http://stackoverflow.com/questions/3801469/how-to-catch-errnoeconnreset-class-in-case-when
    case fobj
    when BagAggregator
      return DigitalObject::Group if (fobj.datastreams['DC'].dc_type & DigitalObject::Group.valid_dc_types).length > 0
    when ContentAggregator
      return DigitalObject::Item if (fobj.datastreams['DC'].dc_type & DigitalObject::Item.valid_dc_types).length > 0
    when GenericResource
      return DigitalObject::Asset if (fobj.datastreams['DC'].dc_type & DigitalObject::Asset.valid_dc_types).length > 0
    end

    raise 'Cannot determine type of fedora object ' + fobj.class.to_s + ' with pid: ' + fobj.pid + ' and dc_type: ' + fobj.datastreams['DC'].dc_type.inspect
  end

  def digital_object_type
    @digital_object_type ||= DigitalObjectType.find_by(string_key: self.class::DIGITAL_OBJECT_TYPE_STRING_KEY)
    return @digital_object_type
  end

  def get_enabled_dynamic_fields

    # If there's only one project, things are simple.  Just return the EnabledDynamicFields for that project.
    # For now, the idea is that objects can be published to multiple publish targets, but they're only managed by one project.
    if self.projects.length == 1
      return self.projects.first.get_enabled_dynamic_fields(self.digital_object_type)
    else
      raise 'Not currently supporting objects with more than one project.'
    end

    ## If this DigitalObject has more than one project, this is more complicated because
    ## each project has its own EnabledDynamicField properties, and some may overlap for
    ## the same DynamicField.  (Only one version may be locked, one may have a
    ## default value, one may be required, etc.)
    #
    ## This method's job is to resolve all of the potential merging mess.
    #
    ## Current merge strategy.  Always favor the EnabledDynamicField rules (required, locked, etc.)
    ## of the project with the earlier created date, since the one with the newer date is "borrowing/sharing"
    ## with the original project.
    #
    ## TODO: When importing existing projects into Hyacinth, make sure that the Project gets its created
    ## date from its associated Fedora object.
    #
    #all_enabled_dynamic_fields = []
    ## Always sort projects in the same order so that the enabled_dynamic_field merge order is consistent
    #self.projects.sort_by{|project|project.created}.each do |project|
    #
    #  enabled_dynamic_fields = project.get_enabled_dynamic_fields(self.digital_object_type)
    #
    #  if all_enabled_dynamic_fields.length == 0
    #    all_enabled_dynamic_fields += enabled_dynamic_fields
    #  else
    #    # Only get EnabledDynamicFields with dynamic_field_id values that aren't already in all_enabled_dynamic_fields
    #    current_dynamic_field_id_values = all_enabled_dynamic_fields.map{|enabled_df| enabled_df.dynamic_field_id}
    #    all_enabled_dynamic_fields += enabled_dynamic_fields.select{|enabled_df| current_dynamic_field_id_values.include?(enabled_df) }
    #  end
    #
    #end
    #return all_enabled_dynamic_fields
  end

  def save
    if self.valid?
      DigitalObjectRecord.transaction do
        if self.new_record?
          @fedora_object = self.get_new_fedora_object
          @db_record.pid = @fedora_object.pid
          hyacinth_ds = get_new_hyacinth_datastream
          @fedora_object.add_datastream(hyacinth_ds)
        else
          # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
          @db_record.lock! # Within the established transaction, lock on this object's row.  Remember: "lock!" also reloads object data from the db, so perform all @db_record modifications AFTER this call.
        end
        remove_blank_fields_from_dynamic_field_data!
        set_created_and_updated_data_from_db_record
        set_fedora_hyacinth_ds_data
        set_fedora_project_and_publisher_relationships
        set_fedora_object_state
        set_fedora_object_dc_type
        set_fedora_object_dc_title_and_label

        set_fedora_parent_digital_object_pid_relationships if parent_digital_object_pids_changed?
        set_fedora_obsolete_parent_digital_object_pid_relationships if obsolete_parent_digital_object_pids_changed?

        @db_record.save! # Save timestamps + updates to modifed_by, etc.

        # Handle Fedora timeouts / unreachable host.  Try up to 3 times.
        NUM_FEDORA_RETRY_ATTEMPTS.times { |i|
          begin
            @fedora_object.save
            break
          rescue RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH => e
            remaining_attempts = (NUM_FEDORA_RETRY_ATTEMPTS-1) - i
            if remaining_attempts == 0
              raise e
            else
              Rails.logger.error "Error: Could not connect to fedora. (#{e.class.to_s + ': ' + e.message}).  Will retry #{remaining_attempts} more #{remaining_attempts == 1 ? 'time' : 'times'} (after a #{DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS} second delay)."
              sleep DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS
            end
          end
        }

        if parent_digital_object_pids_changed?

          removed_parents = parent_digital_object_pids_was - parent_digital_object_pids
          new_parents = parent_digital_object_pids - parent_digital_object_pids_was

          # Parent changes MUST be saved after Fedora object changes because they rely on the state of the live Fedora Object.
          # Update all removed parents AND new parents so they have the latest member changes.

          if HYACINTH['treat_fedora_resource_index_updates_as_immediate']
            # If Fedora's Resource Index is set to update IMMEDIATELY
            # after object modification, we can use the lines below,
            # simply re-saving each affected parent.  If not, this is unsafe to use.
            # Resource Update flush settings must be configured in fedora.fcfg.

            (removed_parents + new_parents).each do |digital_obj_pid|
              parent_obj = DigitalObject::Base.find(digital_obj_pid)
              unless parent_obj.save
                @errors.add(:parent_digital_object, parent_obj.errors)
              end
            end
          else

            # If Fedora Resource Index changes aren't immediate, we canot simply re-save the parents.
            # The Resource Index is unlikely to have been updated at this point (and sometimes takes 10
            # seconds or longer to update).  We'll need to manually remove pid references from parent lists
            # of ordered_child_digital_object_pids.

            removed_parents.each do |digital_obj_pid|
              removed_parent_obj = DigitalObject::Base.find(digital_obj_pid)
              removed_parent_obj.remove_ordered_child_digital_object_pid(self.pid)
              unless removed_parent_obj.save
                @errors.add(:obsolete_parent_digital_object_pid, removed_parent_obj.errors)
              end
            end

            new_parents.each do |digital_obj_pid|
              new_parent_obj = DigitalObject::Base.find(digital_obj_pid)
              new_parent_obj.add_ordered_child_digital_object_pid(self.pid)
              unless new_parent_obj.save
                @errors.add(:parent_digital_object_pid, new_parent_obj.errors)
                return false
              end
            end

          end

          if @errors.present?
            return false
          end

        end

        @db_record.save! # Save timestamps + updates to modifed_by, etc.

        self.update_index
        return true
      end
    end
    return false
  end

  def publish
    # Save all XmlDatastreams that have data

    # TODO: Temporarily doing a manual hard-coded save of descMetadata for now.  Eventually handle all custom XmlDatastreams in a non-hard-coded way.
    ds_name = 'descMetadata'
    if @fedora_object.datastreams[ds_name].present?
      ds = @fedora_object.datastreams[ds_name]
    else
      # Create datastream if it doesn't exist
      ds = @fedora_object.create_datastream(ActiveFedora::Datastream, ds_name,
        :controlGroup => 'M',
        :mimeType => 'text/xml',
        :dsLabel => ds_name,
        :versionable => true,
        :blob => ''
      )
      @fedora_object.add_datastream(ds)
    end
    ds.content = self.render_xml_datastream(XmlDatastream.find_by(string_key: ds_name))

    # Save ordered child data to structMetadata datastream
    struct_ds_name = 'structMetadata'
    if self.ordered_child_digital_object_pids.present?

      #TODO: Use Solr to get titles of child objects.  Fall back to "Item 1", "Item 2", etc. if a title is not found for some reason.

      struct_ds = Cul::Scv::Hydra::Datastreams::StructMetadata.new(nil, 'structMetadata', label:'Sequence', type:'logical')
      ordered_child_digital_object_pids.each_with_index do |pid, index|
        struct_ds.create_div_node(nil, {order: (index+1), label: "Item #{index+1}", contentids: pid})
      end
	  	@fedora_object.datastreams[struct_ds_name].ng_xml = struct_ds.ng_xml
    else
      # No child objects.  If struct datastream is present, perform cleanup by deleting it.
      if @fedora_object.datastreams[struct_ds_name].present?
        @fedora_object.datastreams[struct_ds_name].delete
      end
    end

    # Handle Fedora timeouts / unreachable host.  Try up to 3 times.
    NUM_FEDORA_RETRY_ATTEMPTS.times { |i|
      begin
        @fedora_object.save
        break
      rescue RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH => e
        remaining_attempts = (NUM_FEDORA_RETRY_ATTEMPTS-1) - i
        if remaining_attempts == 0
          raise e
        else
          Rails.logger.error "Error: Could not connect to fedora. (#{e.class.to_s + ': ' + e.message}).  Will retry #{remaining_attempts} more #{remaining_attempts == 1 ? 'time' : 'times'} (after a #{DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS} second delay)."
          sleep DELAY_BETWEEN_FEDORA_RETRY_ATTEMPTS
        end
      end
    }

    return false if @errors.present?
      
    # Tell external publish targets to reindex this object
    self.publish_targets.each do |publish_target|
      publish_url = publish_target.publish_url
      api_key = publish_target.api_key
      json_response = JSON(RestClient.post publish_url, {pid: self.pid, api_key: api_key})
      
      unless json_response['success'] && json_response['success'].to_s == 'true'
        @errors.add(:publish_target, 'Error encountered while publishing to ' + publish_target.display_label)
      end
    end
    
    return @errors.blank?
    
  end

  def next_pid
    self.projects.first.next_pid
  end

  def self.valid_dc_types
    return self::VALID_DC_TYPES
  end

  def allowed_publish_targets
    publish_targets_to_return = []
    self.projects.each do |project|
      publish_targets_to_return += project.publish_targets
    end
    publish_targets_to_return.uniq!
    return publish_targets_to_return
  end

  ######################
  # JSON Serialization #
  ######################

  # JSON representation
  def as_json(options={})
    return {
      pid: self.pid,
      title: self.get_title,
      state: @fedora_object ? @fedora_object.state : 'A',
      dc_type: self.dc_type,
      projects: self.projects,
      allowed_publish_targets: self.allowed_publish_targets,
      publish_targets: self.publish_targets,
      digital_object_type: self.digital_object_type,
      dynamic_field_data: @dynamic_field_data,
      ordered_child_digital_object_pids: self.ordered_child_digital_object_pids,
      parent_digital_object_pids: self.parent_digital_object_pids
    }

  end

end
