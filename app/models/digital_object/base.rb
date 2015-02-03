class DigitalObject::Base

  include DigitalObject::IndexAndSearch
  include DigitalObject::Validation
  include DigitalObject::Fedora
  include DigitalObject::DigitalObjectRecord
  include DigitalObject::DynamicField

  attr_accessor :projects, :parent_digital_object_pids, :ordered_child_digital_object_pids, :created_by, :updated_by, :state, :struct_data, :dc_type
  attr_reader :errors, :fedora_object, :updated_at, :created_at, :dynamic_field_data

  VALID_DC_TYPES = [] # There are no valid dc types for DigitalObject::Base

  def initialize(digital_object_record=::DigitalObjectRecord.new, fedora_obj=nil)
    raise 'The DigitalObject::Base class cannot be instantiated.  You can only instantiate subclasses like DigitalObject::Item' if self.class == DigitalObject
    @db_record = digital_object_record
    @fedora_object = fedora_obj

    if self.new_record?
      @projects = []
      @parent_digital_object_pids = []
      @ordered_child_digital_object_pids = []
      @dynamic_field_data = {}
      @state = 'A'
    else
      # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
      @db_record.with_lock do # with_lock creates a transaction and locks on the called object's row
        load_created_and_updated_data_from_db_record!
        load_parent_digital_object_pid_relationships_from_fedora_object!
        load_ordered_child_digital_object_pids_from_fedora_object!
        load_state_from_fedora_object!
        load_dc_type_from_fedora_object!
        load_project_relationships_from_fedora_object!
        load_dynamic_field_data_from_fedora_object!
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

  # Marks a record as inactive
  def destroy
    self.state = 'D' # A state of 'D' means "deleted" in Fedora
    old_parent_digital_objects = @parent_digital_object_pids
    self.clear_fedora_parent_digital_object_pids_and_set_fedora_relationships_as_as_obsolete

    if self.save
      # Update parent object ordered_child_digital_object_pids by removing this pid from their lists
      if old_parent_digital_objects.present?
        old_parent_digital_objects.each do |old_parent_digital_object_pid|
          old_parent_digital_object = DigitalObject::Base.find(old_parent_digital_object_pid)
          if old_parent_digital_object.ordered_child_digital_object_pids.include?(self.pid)
            old_parent_digital_object.ordered_child_digital_object_pids.delete(self.pid)
            old_parent_digital_object.save
          end
        end
      end
      return true
    else
      return false
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
      raise "Couldn't find DigitalObject with pid #{pid}"
    end

    fobj = ActiveFedora::Base.find(pid)
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
    when Concept
      return DigitalObject::Exhibition if (fobj.datastreams['DC'].dc_type & DigitalObject::Exhibition.valid_dc_types).length > 0
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
        set_fedora_dynamic_field_data
        set_fedora_project_relationships
        set_fedora_object_state
        set_fedora_object_dc_type
        set_fedora_ordered_child_digital_object_pids
        set_fedora_parent_digital_object_pid_relationships
        set_fedora_object_dc_title_and_label
        @fedora_object.save
        @db_record.save! # Save timestamps + updates to modifed_by, etc.

        if parent_digital_object_pids.present?
          parent_digital_object_pids.each do |parent_digital_object_pid|
            parent_digital_object = DigitalObject::Base.find(parent_digital_object_pid)
            # Append this record's pid to the end of its parent_digital_object's
            # ordered_child_digital_object_pids list if it's not already in the list.
            # This logic handles creation of new child records and easy addition of
            # existing child records to existing parents.
            unless parent_digital_object.ordered_child_digital_object_pids.include?(self.pid)
              parent_digital_object.ordered_child_digital_object_pids << self.pid
              parent_digital_object.save
            end
          end
        end

        self.update_index
        return true
      end
    end
    return false
  end

  def next_pid
    self.projects.first.next_pid
  end

  def self.valid_dc_types
    return self::VALID_DC_TYPES
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
      digital_object_type: self.digital_object_type,
      dynamic_field_data: @dynamic_field_data,
      ordered_child_digital_object_pids: self.ordered_child_digital_object_pids,
      parent_digital_object_pids: self.parent_digital_object_pids
    }

  end

end
