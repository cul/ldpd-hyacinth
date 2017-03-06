module DigitalObject::Fedora
  extend ActiveSupport::Concern
  included do
    include Read
    include Write
    include Detect
  end

  PROJECT_MEMBERSHIP_PREDICATE = :is_constituent_of
  HYACINTH_CORE_DATASTREAM_NAME = 'hyacinth_core'
  HYACINTH_STRUCT_DATASTREAM_NAME = 'hyacinth_struct'

  # Get a new, unsaved, appropriately-configured instance of the right tyoe of Fedora object a DigitalObject subclass
  def create_fedora_object
    require_subclass_override!
  end

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
      add_extra_controlled_term_uri_data_to_dynamic_field_data!(@dynamic_field_data)

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
      @publish_target_pids = @fedora_object.relationships(:publisher).to_a.map { |val| val.gsub('info:fedora/', '') }
    end

    def load_ezid_from_fedora_object!
      @doi = @fedora_object.relationships(:ezid_doi).first
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
      values = @parent_digital_object_pids.map { |object_pid| Hyacinth::ActiveFedoraBaseWithCast.find(object_pid).internal_uri }
      set_fedora_object_relationship(:cul_member_of, values)
    end

    # Sets :cul_obsolete_from RELS-EXT attributes for parent fedora objects
    def set_fedora_obsolete_parent_digital_object_pid_relationships
      # This method also ensures that we only save pids for Objects that actually exist.  Invalid pids will cause it to fail.
      values = @parent_digital_object_pids.map { |object_pid| Hyacinth::ActiveFedoraBaseWithCast.find(object_pid).internal_uri }
      set_fedora_object_relationship(:cul_obsolete_from, values)
    end

    def set_fedora_project_and_publisher_relationships
      set_fedora_object_relationship(PROJECT_MEMBERSHIP_PREDICATE, @project.fedora_object.internal_uri)
      # Retrieve publish targets before setting in order to verify that they exist
      # TODO: Do this through solr rather than Fedora because it's faster
      publish_targets = @publish_target_pids.map { |publish_target_pid| DigitalObject::Base.find(publish_target_pid) }
      values = publish_targets.map { |publish_target| publish_target.fedora_object.internal_uri }
      set_fedora_object_relationship(:publisher, values)
    end

    def set_fedora_object_ezid_doi
      # store the EZID DOI identifier in RELS-EXT of fedora object
      set_fedora_object_relationship(:ezid_doi, doi)
    end

    # Prepares a hash for serialization to the hyacinth ds upon Fedora write
    def data_for_hyacinth_ds
      # Using Marshal to make a copy so we don't modifiy the in-memory copy, then saving the modified copy to Fedora
      { DigitalObject::DynamicField::DATA_KEY => remove_extra_controlled_term_uri_data_from_dynamic_field_data!(Marshal.load(Marshal.dump(@dynamic_field_data))) }
    end

    def set_fedora_hyacinth_ds_data
      # Create required hyacinth datastreams if they don't exist
      create_required_hyacinth_datastreams_if_not_exist!

      # Set HYACINTH_CORE_DATASTREAM_NAME data
      @fedora_object.datastreams[HYACINTH_CORE_DATASTREAM_NAME].content = JSON.generate(data_for_hyacinth_ds)
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

    def save_datastreams
      save_xml_datastreams
      save_structure_datastream
      true
    end

    def save_xml_datastreams
      # Save all XmlDatastreams that have data

      # TODO: Temporarily doing a manual hard-coded save of descMetadata for now.  Eventually handle all custom XmlDatastreams in a non-hard-coded way.
      ds_name = 'descMetadata'
      if @fedora_object.datastreams[ds_name].present?
        ds = @fedora_object.datastreams[ds_name]
      else
        # Create datastream if it doesn't exist
        ds = @fedora_object.create_datastream(
          ActiveFedora::Datastream, ds_name,
          controlGroup: 'M',
          mimeType: 'text/xml',
          dsLabel: ds_name,
          versionable: true,
          blob: ''
        )
        @fedora_object.add_datastream(ds)
      end
      ds.content = render_xml_datastream(XmlDatastream.find_by(string_key: ds_name))
    end

    def save_structure_datastream
      # Save ordered child data to structMetadata datastream
      struct_ds_name = 'structMetadata'
      if ordered_child_digital_object_pids.present?
        # Use Solr to verify existence of child items in Hyacinth and get titles of child objects.
        # Do lookup as admin user
        # Fall back to "Item 1", "Item 2", etc. if a title is not found for some reason.
        titles_for_pids = DigitalObject::Base.titles_for_pids(ordered_child_digital_object_pids + ['something:else'], User.find_by(is_admin: true))
        struct_ds = Cul::Hydra::Datastreams::StructMetadata.new(nil, 'structMetadata', label: 'Sequence', type: 'logical')
        ordered_child_digital_object_pids.each_with_index do |pid, index|
          title = titles_for_pids[pid]
          # If title is nil, that means that this object wasn't found in Hyacinth.
          # Might be an unimported object that is only in Fedora. For now, don't
          # include unimported objects the generated struct map.
          next if title.nil?
          struct_ds.create_div_node(nil, order: (index + 1), label: (title.blank? ? "Item #{index + 1}" : title), contentids: pid)
        end
        @fedora_object.datastreams[struct_ds_name].ng_xml = struct_ds.ng_xml
      else
        # No child objects.  If struct datastream is present, perform cleanup by deleting it.
        @fedora_object.datastreams[struct_ds_name].delete if @fedora_object.datastreams[struct_ds_name].present?
      end
    end
  end

  module Detect
    extend ActiveSupport::Concern

    module ClassMethods
      def detect_asset(obj, dc_types = [])
        obj.is_a?(GenericResource) && (dc_types & DigitalObject::Asset.valid_dc_types).length > 0
      end

      def detect_file_system(obj, dc_types = [])
        obj.is_a?(Collection) && (dc_types & DigitalObject::FileSystem.valid_dc_types).length > 0
      end

      def detect_publish_target(obj, dc_types = [])
        obj.is_a?(Concept) && (dc_types & DigitalObject::PublishTarget.valid_dc_types).length > 0
      end

      def detect_group(obj, dc_types = [])
        obj.is_a?(Collection) && (dc_types & DigitalObject::Group.valid_dc_types).length > 0
      end

      def detect_item(obj, dc_types = [])
        obj.is_a?(ContentAggregator) && (dc_types & DigitalObject::Item.valid_dc_types).length > 0
      end

      # Returns the DigitalObject::Something class for the given Fedora object.
      # Only handles types expected by Hyacinth
      def get_class_for_fedora_object(fobj)
        if fobj.datastreams['DC'] && fobj.datastreams['DC'].dc_type
          obj_dc_type = fobj.datastreams['DC'].dc_type # returned dc_type is an array

          # These methods defined in DigitalObject::Fedora::Detect
          # Ultimately should be moved to the subclasses themselves.
          type_map = {
            DigitalObject::Item => method_as_proc(:detect_item),
            DigitalObject::Asset => method_as_proc(:detect_asset),
            DigitalObject::Group => method_as_proc(:detect_group),
            DigitalObject::FileSystem => method_as_proc(:detect_file_system),
            DigitalObject::PublishTarget => method_as_proc(:detect_publish_target)
          }
          mapped_type = type_map.detect { |_candidate, detector| detector.call(fobj, obj_dc_type) }
          return mapped_type.first if mapped_type
        end

        raise "Cannot determine Hyacinth type for fedora object #{fobj.pid} with class #{fobj.class} and dc_type: #{fobj.datastreams['DC'].dc_type}"
      end

      def method_as_proc(method_name)
        proc { |*args| send method_name, *args }
      end
    end
  end
end
