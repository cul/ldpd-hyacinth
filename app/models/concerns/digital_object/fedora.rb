module DigitalObject::Fedora
  extend ActiveSupport::Concern

  PROJECT_MEMBERSHIP_PREDICATE = :is_constituent_of
  HYACINTH_DATASTREAM_NAME = 'hyacinth'
  HYACINTH_STRUCT_DATASTREAM_NAME = 'hyacinth_struct'

  ###############################
  # General data access methods #
  ###############################

  def get_hyacinth_ds_data
    hyacinth_ds = @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME]
    if hyacinth_ds.present? && hyacinth_ds.content.present?
      return JSON(hyacinth_ds.content)
    end
    return {}
  end
  
  def get_hyacinth_struct_ds_data
    hyacinth_struct_ds = @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME]
    if hyacinth_struct_ds.present? && hyacinth_struct_ds.content.present?
      return JSON(hyacinth_struct_ds.content)
    end
    return []
  end

  ######################################
  # Fedora object data writing methods #
  ######################################

  def set_fedora_object_dc_title_and_label
    title = self.get_title
    @fedora_object.label = title
    @fedora_object.datastreams["DC"].dc_title = title
  end

  def set_fedora_object_state
    @fedora_object.state = self.state
  end

  def set_fedora_object_dc_type
    @fedora_object.datastreams['DC'].dc_type = self.dc_type
  end
  
  def set_fedora_object_dc_identifiers
    @fedora_object.datastreams['DC'].dc_identifier = @identifiers.uniq
  end

  # Sets :cul_member_of  RELS-EXT attributes for parent fedora objects
  def set_fedora_parent_digital_object_pid_relationships
    # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.

    # Clear old parent_digital_object relationship
    @fedora_object.clear_relationship(:cul_member_of)

    @parent_digital_object_pids.each do |parent_digital_object_pid|
      obj = ActiveFedora::Base.find(parent_digital_object_pid)
      # Add new parent_digital_object relationship
      @fedora_object.add_relationship(:cul_member_of, obj.internal_uri)
    end

    @fedora_object.datastreams["RELS-EXT"].content_will_change!
  end

  # Sets :cul_obsolete_from RELS-EXT attributes for parent fedora objects
  def set_fedora_obsolete_parent_digital_object_pid_relationships
    # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.

    # Clear old parent_digital_object relationship
    @fedora_object.clear_relationship(:cul_obsolete_from)

    @obsolete_parent_digital_object_pids.each do |obsolete_parent_digital_object_pid|
      obj = ActiveFedora::Base.find(obsolete_parent_digital_object_pid)
      # Add new obsolete_parent_digital_object relationship
      @fedora_object.add_relationship(:cul_obsolete_from, obj.internal_uri)
    end

    @fedora_object.datastreams["RELS-EXT"].content_will_change!
  end

  def set_fedora_project_and_publisher_relationships

    # Clear old project relationship
    @fedora_object.clear_relationship(PROJECT_MEMBERSHIP_PREDICATE)
    
    project_obj = @project.fedora_object
    # Add new project relationship
    @fedora_object.add_relationship(PROJECT_MEMBERSHIP_PREDICATE, project_obj.internal_uri)
    
    # Clear old publish target relationship
    @fedora_object.clear_relationship(:publisher)
    @publish_targets.each do |publish_target|
      publish_target_obj = publish_target.fedora_object
      # Add new project relationship
      @fedora_object.add_relationship(:publisher, publish_target_obj.internal_uri)
    end

    @fedora_object.datastreams["RELS-EXT"].content_will_change!
  end

  def set_fedora_hyacinth_ds_data
    # Create required hyacinth datastreams if they don't exist
    create_required_hyacinth_datastreams_if_not_exist!
    
    # Set Hyacinth data
    copy_of_current_dynamic_field_data = Marshal.load(Marshal.dump(@dynamic_field_data)) # Making a copy so we don't modifiy the in-memory copy, then saving the modified copy to Fedora
    @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME].content = JSON.generate({
      'dynamic_field_data' => remove_extra_uri_data_from_dynamic_field_data!(copy_of_current_dynamic_field_data)
    })
    # Set Hyacinth struct data
    @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME].content = JSON.generate(@ordered_child_digital_object_pids)
  end

  ######################################
  # Fedora object data loading methods #
  ######################################

  def load_state_from_fedora_object!
    self.state = @fedora_object.state
  end

  def load_dc_type_from_fedora_object!
    self.dc_type = @fedora_object.datastreams['DC'].dc_type
    self.dc_type = self.dc_type[0] if self.dc_type.is_a?(Array)
  end
  
  def load_dc_identifiers_from_fedora_object!
    @identifiers = @fedora_object.datastreams['DC'].dc_identifier.to_a.uniq # Must cast to array, otherwise we'll be working with a weird Array-like object that isn't actually an array and behaves unpredictably
  end
  
  def load_parent_digital_object_pid_relationships_from_fedora_object!
    @parent_digital_object_pids = @fedora_object.relationships(:cul_member_of).map{|val| val.gsub('info:fedora/', '') }
    @obsolete_parent_digital_object_pids = @fedora_object.relationships(:cul_obsolete_from).map{|val| val.gsub('info:fedora/', '') }
  end

  def load_fedora_hyacinth_ds_data_from_fedora_object!
    
    # Load Hyacinth data
    hyacinth_data = get_hyacinth_ds_data()
    @dynamic_field_data = hyacinth_data['dynamic_field_data'] || {}
    self.add_extra_uri_data_to_dynamic_field_data!(@dynamic_field_data)
    
    # Load Hyacinth struct data
    @ordered_child_digital_object_pids = get_hyacinth_struct_ds_data()
    
    if HYACINTH['treat_fedora_resource_index_updates_as_immediate']
      # If and only if Fedora Resource Index updates are set to be immediate, we can rely on the index for
      # aggregating missing memberOf values and appending them to this list.  If Resource Index updates aren't
      # immediate, this is unsafe.  Resource Update flush settings must be configured in fedora.fcfg.

      # - To be safe, do a Fedora Resource Index search for all upward-pointing member relationships from child objects:
      # - Append missing members
      # - Remove nonexistent members
      risearch_members = Cul::Hydra::RisearchMembers.get_direct_member_pids(self.pid)

      # Example of logic below:
      #>>>> ( [1, 2, 7] | [6, 7] ) & [7, 6]
      #  => [6, 7]
      # Maintains order of existing items, adds missing items, cleans up nonexistent items
      @ordered_child_digital_object_pids = (@ordered_child_digital_object_pids | risearch_members) & risearch_members
    end

  end

  def load_project_and_publisher_relationships_from_fedora_object!
    # Get project relationships
    pid = @fedora_object.relationships(PROJECT_MEMBERSHIP_PREDICATE).map{|val| val.gsub('info:fedora/', '') }.first
    raise "Missing project for DigitalObject #{self.pid}. This needs to be fixed." if pid.nil?
    @project = Project.find_by(pid: pid)
    raise "Could not find project with pid #{pid} for DigitalObject #{self.pid}." if @project.nil?

    # Get publish target relationships
    pids = @fedora_object.relationships(:publisher).map{|val| val.gsub('info:fedora/', '') }
    @publish_targets = PublishTarget.where(pid: pids).to_a
    if pids.length != @publish_targets.length
      raise "Could not load all Publish Targets for DigitalObject #{self.pid}. " +
        "The following Fedora objects have not been imported into Hyacinth as Publish targets: " + (pids - @publish_targets.map{|pub|pub.pid}).inspect
    end
  end
  
  def create_required_hyacinth_datastreams_if_not_exist!
    if @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME].nil?
      hyacinth_ds = get_new_hyacinth_datastream
      @fedora_object.add_datastream(hyacinth_ds)
    end
    
    if @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME].nil?
      hyacinth_struct_ds = get_new_hyacinth_struct_datastream
    @fedora_object.add_datastream(hyacinth_struct_ds)
    end
  end

  def get_new_hyacinth_datastream
    hyacinth_data = {}
    hyacinth_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, HYACINTH_DATASTREAM_NAME,
      :controlGroup => 'M',
      :mimeType => 'application/json',
      :dsLabel => HYACINTH_DATASTREAM_NAME,
      :versionable => true,
      :blob => hyacinth_data.to_json
    )
    return hyacinth_ds
  end
  
  def get_new_hyacinth_struct_datastream
    struct_data = {}
    hyacinth_ds = @fedora_object.create_datastream(ActiveFedora::Datastream, HYACINTH_STRUCT_DATASTREAM_NAME,
      :controlGroup => 'M',
      :mimeType => 'application/json',
      :dsLabel => HYACINTH_STRUCT_DATASTREAM_NAME,
      :versionable => false,
      :blob => struct_data.to_json
    )
    return hyacinth_ds
  end

end
