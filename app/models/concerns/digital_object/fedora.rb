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
    hyacinth_data = get_hyacinth_data()
    # Making a copy so we don't modifiy the in-memory copy, then saving the modified copy to Fedora
    copy_of_current_dynamic_field_data = Marshal.load(Marshal.dump(@dynamic_field_data))
    hyacinth_data['dynamic_field_data'] = remove_extra_uri_data_from_dynamic_field_data!(copy_of_current_dynamic_field_data)
    hyacinth_data['ordered_child_digital_object_pids'] = @ordered_child_digital_object_pids
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
  
  def load_dc_identifiers_from_fedora_object!
    @identifiers = @fedora_object.datastreams['DC'].dc_identifier.to_a.uniq # Must cast to array, otherwise we'll be working with a weird Array-like object that isn't actually an array and behaves unpredictably
  end
  
  def load_parent_digital_object_pid_relationships_from_fedora_object!
    @parent_digital_object_pids = @fedora_object.relationships(:cul_member_of).map{|val| val.gsub('info:fedora/', '') }
    @obsolete_parent_digital_object_pids = @fedora_object.relationships(:cul_obsolete_from).map{|val| val.gsub('info:fedora/', '') }
  end

  # Returns hash of format {'controlled_term_dynamic_field_string_key' => 'parent_dynamic_field_group_string_key'}
  def get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys()
    return ::DynamicField.where(dynamic_field_type: DynamicField::Type::CONTROLLED_TERM).map{|df| [df.string_key, df.controlled_vocabulary_string_key] }
  end

  def add_extra_uri_data_to_dynamic_field_data!(dynamic_field_data)
    #hashes_to_modify = [] # TODO: Aggregate all hashes into array and do single URI lookup for better performance (fewer UriService calls)
    
    get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
      Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
        uri = dynamic_field_group_value[controlled_term_df_string_key]
        raise 'Expected string, but got ' + uri.class.name unless uri.is_a?(String)
        term = UriService.client.find_term_by_uri(uri)
        dynamic_field_group_value[controlled_term_df_string_key] = term
      end
    end
    return dynamic_field_data
  end
  
  def remove_extra_uri_data_from_dynamic_field_data!(dynamic_field_data)
    
    # We only need to remove uri display labels is there are elements that contain the key "uri" somewhere in the dynamic_field_data
    if Hyacinth::Utils::HashUtils::find_nested_hash_values(dynamic_field_data, 'uri').length > 0
      
      get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
        Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
          if dynamic_field_group_value[controlled_term_df_string_key]['uri'].present?
            uri = dynamic_field_group_value[controlled_term_df_string_key]['uri']
            dynamic_field_group_value[controlled_term_df_string_key] = uri
          end
        end
      end
      
    end
    
    return dynamic_field_data
  end
  
  def register_new_uris_and_values_for_dynamic_field_data!(dynamic_field_data)
    # We only need to register new uri values if there are elements that contain the key "uri" somewhere in the dynamic_field_data
    if Hyacinth::Utils::HashUtils::find_nested_hash_values(dynamic_field_data, 'uri').length > 0
      
      get_controlled_term_field_string_keys_to_controlled_vocabulary_string_keys().each do |controlled_term_df_string_key, controlled_vocabulary_string_key|
        Hyacinth::Utils::HashUtils::find_nested_hashes_that_contain_key(dynamic_field_data, controlled_term_df_string_key).each do |dynamic_field_group_value|
          if dynamic_field_group_value[controlled_term_df_string_key]['uri'].present?
            
            uri = nil
            value = nil
            additional_fields = {}
            dynamic_field_group_value[controlled_term_df_string_key].each do |key, val|
              if key == 'uri'
                uri = val
              elsif key == 'value'
                value = val
              else
                additional_fields[key] = val
              end
            end
            
            if uri.blank? && value.present?
              # If URI is blank and a value is present, then we'll assign this value to a temporary term, only considering the string value
              
              temporary_term = UriService.client.create_term(UriService::TermType::TEMPORARY, {vocabulary_string_key: controlled_vocabulary_string_key, value: value})
              temporary_term['uri']
              dynamic_field_group_value[controlled_term_df_string_key] = term # Update dynamic_field_data
            else
              # URI is present, so we'll check whether it exists already.
              # If it does, retrieve its controlled value and update dynamic_field_data to correct errors
              # If it doesn't exist, register it as a new EXTERNAL term
              term = UriService.client.find_term_by_uri(uri)
              if term.nil?
                new_external_term = UriService.client.create_term(UriService::TermType::EXTERNAL, {vocabulary_string_key: controlled_vocabulary_string_key, value: value, uri: uri, additional_fields: additional_fields})
                dynamic_field_group_value[controlled_term_df_string_key] = new_external_term # Update dynamic_field_data
              else
                # Term exists. Assign term data to record.
                dynamic_field_group_value[controlled_term_df_string_key] = term # Update dynamic_field_data
              end
            end
            
          end
        end
      end
      
    end
    
  end

  def load_fedora_hyacinth_ds_data_from_fedora_object!
    hyacinth_data = get_hyacinth_data()
    @dynamic_field_data = hyacinth_data['dynamic_field_data'] || {}
    self.add_extra_uri_data_to_dynamic_field_data!(@dynamic_field_data)
    @ordered_child_digital_object_pids = hyacinth_data['ordered_child_digital_object_pids'] || []

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

end
