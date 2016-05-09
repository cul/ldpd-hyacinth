module DigitalObject::Fedora
  extend ActiveSupport::Concern
  included do
    include Read
    include Write
  end

  PROJECT_MEMBERSHIP_PREDICATE = :is_constituent_of
  HYACINTH_CORE_DATASTREAM_NAME = 'hyacinth_core'
  HYACINTH_STRUCT_DATASTREAM_NAME = 'hyacinth_struct'

  module Read
    ###############################
    # General data access methods #
    ###############################

    def fedora_hyacinth_ds_data
      hyacinth_ds = @fedora_object.datastreams[HYACINTH_CORE_DATASTREAM_NAME]
      if hyacinth_ds.present? && hyacinth_ds.content.present?
        return JSON(hyacinth_ds.content)
      end
      {}
    end

    def fedora_hyacinth_struct_ds_data
      hyacinth_struct_ds = @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME]
      if hyacinth_struct_ds.present? && hyacinth_struct_ds.content.present?
        return JSON(hyacinth_struct_ds.content)
      end
      []
    end

    ######################################
    # Fedora object data loading methods #
    ######################################

    def load_state_from_fedora_object!
      self.state = @fedora_object.state
    end

    def load_dc_type_from_fedora_object!
      self.dc_type = Array(@fedora_object.datastreams['DC'].dc_type)[0]
    end

    def load_dc_identifiers_from_fedora_object!
      @identifiers = @fedora_object.datastreams['DC'].dc_identifier.to_a.uniq # Must cast to array, otherwise we'll be working with a weird Array-like object that isn't actually an array and behaves unpredictably
    end

    def load_parent_digital_object_pid_relationships_from_fedora_object!
      @parent_digital_object_pids = @fedora_object.relationships(:cul_member_of).map { |val| val.gsub('info:fedora/', '') }
      @obsolete_parent_digital_object_pids = @fedora_object.relationships(:cul_obsolete_from).map { |val| val.gsub('info:fedora/', '') }
    end

    def load_fedora_hyacinth_ds_data_from_fedora_object!
      # Load Hyacinth data
      hyacinth_data = fedora_hyacinth_ds_data
      @dynamic_field_data = hyacinth_data.fetch(DigitalObject::DynamicField::DATA_KEY, {})
      add_extra_uri_data_to_dynamic_field_data!(@dynamic_field_data)

      # Load Hyacinth struct data
      @ordered_child_digital_object_pids = fedora_hyacinth_struct_ds_data

      # If and only if Fedora Resource Index updates are set to be immediate, we can rely on the index for
      # aggregating missing memberOf values and appending them to this list.  If Resource Index updates aren't
      # immediate, this is unsafe.  Resource Update flush settings must be configured in fedora.fcfg.

      # - To be safe, do a Fedora Resource Index search for all upward-pointing member relationships from child objects:
      # - Append missing members
      # - Remove nonexistent members
      risearch_members = Cul::Hydra::RisearchMembers.get_direct_member_pids(pid, true)

      # Example of logic below:
      # >>>> ( [1, 2, 7] | [6, 7] ) & [7, 6]
      #  => [6, 7]
      # Maintains order of existing items, adds missing items, cleans up nonexistent items
      @ordered_child_digital_object_pids = (@ordered_child_digital_object_pids | risearch_members) & risearch_members
    end

    def load_project_and_publisher_relationships_from_fedora_object!
      # Get project relationships
      project_pid = @fedora_object.relationships(PROJECT_MEMBERSHIP_PREDICATE).map { |val| val.gsub('info:fedora/', '') }.first
      Hyacinth::Utils::Logger.logger.info "Missing project for DigitalObject #{project_pid}. This needs to be fixed." if project_pid.nil?
      @project = project_pid.nil? ? nil : Project.find_by(pid: project_pid)

      # Get publish target relationships
      pids = @fedora_object.relationships(:publisher).map { |val| val.gsub('info:fedora/', '') }
      @publish_targets = PublishTarget.where(pid: pids).to_a
      targets_match = pids.length == @publish_targets.length
      raise "Could not load all Publish Targets for DigitalObject #{pid}. " \
        "The following Fedora objects have not been imported into Hyacinth as Publish targets: " \
        "#{(pids - @publish_targets.map(&:pid)).inspect}" unless targets_match
    end
  end

  module Write
    ######################################
    # Fedora object data writing methods #
    ######################################

    def set_fedora_object_dc_title_and_label
      title = get_title
      @fedora_object.label = title
      @fedora_object.datastreams["DC"].dc_title = title
    end

    def set_fedora_object_state
      @fedora_object.state = state
    end

    def set_fedora_object_dc_type
      @fedora_object.datastreams['DC'].dc_type = dc_type
    end

    def set_fedora_object_dc_identifiers
      @fedora_object.datastreams['DC'].dc_identifier = @identifiers.uniq
    end

    def set_fedora_object_relationship(predicate, values)
      # Clear old relationship
      @fedora_object.clear_relationship(predicate)
      Array(values).each { |value| @fedora_object.add_relationship(predicate, value) }
      @fedora_object.datastreams["RELS-EXT"].content_will_change!
    end

    # Sets :cul_member_of  RELS-EXT attributes for parent fedora objects
    def set_fedora_parent_digital_object_pid_relationships
      # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.
      values = @parent_digital_object_pids.map { |object_pid| ActiveFedora::Base.find(object_pid).internal_uri }
      set_fedora_object_relationship(:cul_member_of, values)
    end

    # Sets :cul_obsolete_from RELS-EXT attributes for parent fedora objects
    def set_fedora_obsolete_parent_digital_object_pid_relationships
      # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.
      values = @parent_digital_object_pids.map { |object_pid| ActiveFedora::Base.find(object_pid).internal_uri }
      set_fedora_object_relationship(:cul_obsolete_from, values)
    end

    def set_fedora_project_and_publisher_relationships
      set_fedora_object_relationship(PROJECT_MEMBERSHIP_PREDICATE, @project.fedora_object.internal_uri)

      values = @publish_targets.map { |publish_target| publish_target.fedora_object.internal_uri }
      set_fedora_object_relationship(:publisher, values)
    end

    def set_fedora_hyacinth_ds_data
      # Create required hyacinth datastreams if they don't exist
      create_required_hyacinth_datastreams_if_not_exist!

      # Set HYACINTH_CORE_DATASTREAM_NAME data
      copy_of_current_dynamic_field_data = Marshal.load(Marshal.dump(@dynamic_field_data)) # Making a copy so we don't modifiy the in-memory copy, then saving the modified copy to Fedora
      @fedora_object.datastreams[HYACINTH_CORE_DATASTREAM_NAME].content = JSON.generate(
        DigitalObject::DynamicField::DATA_KEY => remove_extra_uri_data_from_dynamic_field_data!(copy_of_current_dynamic_field_data))
      # Set HYACINTH_STRUCT_DATASTREAM_NAME data
      @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME].content = JSON.generate(@ordered_child_digital_object_pids)
    end

    def create_required_hyacinth_datastreams_if_not_exist!
      @fedora_object.add_datastream(create_hyacinth_core_datastream) if @fedora_object.datastreams[HYACINTH_CORE_DATASTREAM_NAME].nil?

      @fedora_object.add_datastream(create_hyacinth_struct_datastream) if @fedora_object.datastreams[HYACINTH_STRUCT_DATASTREAM_NAME].nil?
    end

    def create_hyacinth_core_datastream
      @fedora_object.create_datastream(
        ActiveFedora::Datastream, HYACINTH_CORE_DATASTREAM_NAME,
        controlGroup: 'M',
        mimeType: 'application/json',
        dsLabel: HYACINTH_CORE_DATASTREAM_NAME,
        versionable: true,
        blob: JSON.generate({}))
    end

    def create_hyacinth_struct_datastream
      @fedora_object.create_datastream(
        ActiveFedora::Datastream, HYACINTH_STRUCT_DATASTREAM_NAME,
        controlGroup: 'M',
        mimeType: 'application/json',
        dsLabel: HYACINTH_STRUCT_DATASTREAM_NAME,
        versionable: false,
        blob: JSON.generate([]))
    end
  end
end
