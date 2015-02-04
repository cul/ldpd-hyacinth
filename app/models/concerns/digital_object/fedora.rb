module DigitalObject::Fedora
  extend ActiveSupport::Concern

  PROJECT_MEMBERSHIP_PREDICATE = :is_constituent_of
  HYACINTH_DATASTREAM_NAME = 'hyacinth'

  ###############################
  # General data access methods #
  ###############################

  def get_hyacinth_data

    hyacinth_ds = @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME]
    if hyacinth_ds.present? && hyacinth_ds.content.present?
      return JSON(hyacinth_ds.content)
    end

    return {}
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

  def set_fedora_ordered_child_digital_object_pids
    hyacinth_data = get_hyacinth_data()
    hyacinth_data['ordered_child_digital_object_pids'] = @ordered_child_digital_object_pids
    @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME].content = hyacinth_data.to_json
  end

  # Sets :cul_member_of RELS-EXT attributes for parent fedora objects
  def set_fedora_parent_digital_object_pid_relationships(options={})
    # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.

    # Clear old parent_digital_object relationship
    @fedora_object.clear_relationship(:cul_member_of)

    @parent_digital_object_pids.each do |parent_digital_object_pid|
      parent_digital_object_obj = ActiveFedora::Base.find(parent_digital_object_pid)
      # Add new parent_digital_object relationship
      if options[:obsolete]
        @fedora_object.add_relationship(:cul_obsolete_from, parent_digital_object_obj.internal_uri)
      else
        @fedora_object.add_relationship(:cul_member_of, parent_digital_object_obj.internal_uri)
      end
    end
    @fedora_object.datastreams["RELS-EXT"].content_will_change!
  end

  # Sets :cul_obsolete_from RELS-EXT attributes for current project pids and clears old :cul_member_of relationships
  # Also clears out old projects
  def clear_fedora_parent_digital_object_pids_and_set_fedora_relationships_as_as_obsolete
    self.set_fedora_parent_digital_object_pid_relationships({obsolete: true})
    @parent_digital_object_pids = []
  end

  def set_fedora_project_relationships
    raise 'Only assets can have more than one project!' if @projects.length > 1 && self.class != DigitalObject::Asset

    # Clear old project relationship
    @fedora_object.clear_relationship(PROJECT_MEMBERSHIP_PREDICATE)
    @projects.each do |project|
      project_obj = project.fedora_object
      # Add new project relationship
      @fedora_object.add_relationship(PROJECT_MEMBERSHIP_PREDICATE, project_obj.internal_uri)
    end
    @fedora_object.datastreams["RELS-EXT"].content_will_change!
  end

  def set_fedora_dynamic_field_data
    hyacinth_data = get_hyacinth_data()
    hyacinth_data['dynamic_field_data'] = @dynamic_field_data
    @fedora_object.datastreams[HYACINTH_DATASTREAM_NAME].content = hyacinth_data.to_json
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

  def load_parent_digital_object_pid_relationships_from_fedora_object!
    @parent_digital_object_pids = @fedora_object.relationships(:cul_member_of).map{|val| val.gsub('info:fedora/', '') }
  end

  def load_ordered_child_digital_object_pids_from_fedora_object!
    hyacinth_data = get_hyacinth_data()
    @ordered_child_digital_object_pids = hyacinth_data['ordered_child_digital_object_pids'] || []
  end

  def load_project_relationships_from_fedora_object!

    pids = @fedora_object.relationships(PROJECT_MEMBERSHIP_PREDICATE).map{|val| val.gsub('info:fedora/', '') }
    @projects = Project.where(pid: pids).to_a
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

  def load_dynamic_field_data_from_fedora_object!
    hyacinth_data = JSON(@fedora_object.datastreams[HYACINTH_DATASTREAM_NAME].content)
    @dynamic_field_data = hyacinth_data['dynamic_field_data'] || {}
  end

end
