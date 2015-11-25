class DigitalObject::Base

  include ActiveModel::Dirty
  include DigitalObject::IndexAndSearch
  include DigitalObject::Validation
  include DigitalObject::Fedora
  include DigitalObject::DigitalObjectRecord
  include DigitalObject::DynamicField
  include DigitalObject::XmlDatastreamRendering

  NUM_FEDORA_RETRY_ATTEMPTS = 3
  DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS = 5

  # For ActiveModel::Dirty
  define_attribute_methods :parent_digital_object_pids, :obsolete_parent_digital_object_pids, :ordered_child_digital_object_pids

  attr_accessor :project, :publish_targets, :identifiers, :created_by, :updated_by, :state, :dc_type, :ordered_child_digital_object_pids
  attr_reader :errors, :fedora_object, :parent_digital_object_pids, :updated_at, :created_at, :dynamic_field_data

  VALID_DC_TYPES = [] # There are no valid dc types for DigitalObject::Base
  
  def require_subclass_override!; raise 'This method must be overridden by a subclass'; end
  
  def initialize()
    raise 'The DigitalObject::Base class cannot be instantiated.  You can only instantiate subclasses like DigitalObject::Item' if self.class == DigitalObject::Base
    @db_record = ::DigitalObjectRecord.new
    @fedora_object = nil
    @project = []
    @publish_targets = []
    @identifiers = []
    @parent_digital_object_pids = []
    @obsolete_parent_digital_object_pids = []
    @ordered_child_digital_object_pids = []
    @dynamic_field_data = {}
    @state = 'A'
    @errors = ActiveModel::Errors.new(self)
  end
  
  def init_from_digital_object_record_and_fedora_object(digital_object_record, fedora_obj)
    @db_record = digital_object_record
    @fedora_object = fedora_obj
    
    # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
    @db_record.with_lock do # with_lock creates a transaction and locks on the called object's row
      load_created_and_updated_data_from_db_record!
      load_parent_digital_object_pid_relationships_from_fedora_object!
      load_state_from_fedora_object!
      load_dc_type_from_fedora_object!
      load_dc_identifiers_from_fedora_object!
      load_project_and_publisher_relationships_from_fedora_object!
      load_fedora_hyacinth_ds_data_from_fedora_object!
    end
  end
  
  # Updates the DigitalObject with the given digital_object_data
  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    
    # Identifiers (multiple)
    if digital_object_data['identifiers']
      self.identifiers = digital_object_data['identifiers']
    end
    
    # Project (only one) -- Only allow setting this if this DigitalObject is a new record
    if self.new_record? && digital_object_data['project']
      project_find_criteria = digital_object_data['project'] # i.e. {string_key: 'proj'} or {pid: 'abc:123'}
      self.project = Project.find_by(project_find_criteria)
      if self.project.nil?
        raise Hyacinth::Exceptions::ProjectNotFoundError, "Could not find Project: #{project_find_criteria.inspect}"
      end
    end
    
    # Publish Targets (multiple)
    if digital_object_data['publish_targets']
      self.publish_targets = []
      digital_object_data['publish_targets'].each do |publish_target_find_criteria|
        publish_target = PublishTarget.find_by(publish_target_find_criteria) # i.e. {string_key: 'target1'} or {pid: 'abc:123'}
        if publish_target.nil?
          raise Hyacinth::Exceptions::PublishTargetNotFoundError, "Could not find Publish Target: #{publish_target_find_criteria.inspect}"
        else
          self.publish_targets.push(publish_target)
        end
      end
    end
    
    # Parent Digital Objects (PID or Identifier)
    if digital_object_data['parent_digital_objects']
      @parent_digital_object_pids = [] # Clear because we're about to set new values
      digital_object_data['parent_digital_objects'].each do |parent_digital_object_find_criteria|
        if parent_digital_object_find_criteria['pid'].present?
          digital_object = DigitalObject::Base.find_by_pid(parent_digital_object_find_criteria['pid'])
        elsif parent_digital_object_find_criteria['identifier'].present?
          digital_object_results = DigitalObject::Base.find_all_by_identifier(parent_digital_object_find_criteria['identifier'])
          if digital_object_results.length == 0
            raise Hyacinth::Exceptions::DigitalObjectNotFoundError, "Could not find parent DigitalObject with find criteria: #{parent_digital_object_find_criteria.inspect}"
          elsif digital_object_results.length == 1
            digital_object = digital_object_results.first
          else
            raise "While linking object to parent objects, expected one DigitalObject, but found #{digital_object_results.length.to_s} DigitalObjects" +
                  "with identifier: #{parent_digital_object_find_criteria['identifier']}.  You'll need to use a pid instead."
          end
        else
          raise 'Invalid parent_digital_object find criteria: ' + parent_digital_object_find_criteria.inspect
        end
        
        add_parent_digital_object(digital_object)
      end
    end
    
    # Ordered child Digital Objects (PID or Identifier)
    if digital_object_data['ordered_child_digital_objects']
      @ordered_child_digital_object_pids = [] # Clear because we're about to set new values
      digital_object_data['ordered_child_digital_objects'].each do |child_digital_object_find_criteria|
        if child_digital_object_find_criteria['pid'].present?
          digital_object = DigitalObject::Base.find_by_pid(child_digital_object_find_criteria['pid'])
        elsif child_digital_object_find_criteria['identifier'].present?
          digital_object_results = DigitalObject::Base.find_all_by_identifier(child_digital_object_find_criteria['identifier'])
          if digital_object_results.length == 0
            raise Hyacinth::Exceptions::DigitalObjectNotFoundError, "Could not find child DigitalObject with find criteria: #{child_digital_object_find_criteria.inspect}"
          elsif digital_object_results.length == 1
            digital_object = digital_object_results.first
          else
            raise "While linking object to parent objects, expected one DigitalObject, but found #{digital_object_results.length.to_s} DigitalObjects" +
                  "with identifier: #{child_digital_object_find_criteria['identifier']}.  You'll need to use a pid instead."
          end
        else
          raise 'Invalid child object find criteria: ' + child_digital_object_find_criteria.inspect
        end
        
        add_ordered_child_digital_object(digital_object)
      end
    end
    
    # Dynamic Field Data
    if digital_object_data['dynamic_field_data'].present?
      self.update_dynamic_field_data(digital_object_data['dynamic_field_data'], merge_dynamic_fields)
    end
    
  end

  # Returns the primary title
  def get_title(return_notitle_placeholder_if_blank=true)
    title = ''
    if @dynamic_field_data['title'] && @dynamic_field_data['title'].first && @dynamic_field_data['title'].first['title_non_sort_portion']
      title += @dynamic_field_data['title'].first['title_non_sort_portion'] + ' '
    end
    title += self.get_sort_title(return_notitle_placeholder_if_blank)
    return title
  end

  # Returns the sort portion of the primary title
  def get_sort_title(return_notitle_placeholder_if_blank=true)
    sort_title = return_notitle_placeholder_if_blank ? '[No Title]' : ''
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
    return if parent_digital_object.nil?
    
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
  def add_ordered_child_digital_object(new_child_digital_object)
    return if new_child_digital_object.nil?
    new_child_digital_object_pid = new_child_digital_object.pid
    
    unless @ordered_child_digital_object_pids.include?(new_child_digital_object_pid)
      @ordered_child_digital_object_pids << new_child_digital_object_pid
    end
  end

  # Marks a record as deleted, but doesn't completely purge it from the system
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

  # Get a new, unsaved, appropriately-configured instance of the right tyoe of Fedora object a DigitalObject subclass
  def get_new_fedora_object; require_subclass_override!; end

  def new_record?
    return @db_record.new_record?
  end

  # Getters

  def pid
    return @fedora_object.present? ? @fedora_object.pid : nil
  end

  # Find/Save/Validate
  
  # Returns true if the given pid exists or if all pids in the given array exist
  def self.exists?(pid_or_pids)
    if pid_or_pids.is_a?(Array)
      return (pid_or_pids.length == DigitalObjectRecord.where?(pid_or_pids).count)
    else
      return DigitalObjectRecord.exists?(pid_or_pids)
    end
  end

  # Finds objects by PID
  def self.find(pid)
    digital_object_record = ::DigitalObjectRecord.find_by(pid: pid)

    if digital_object_record.nil?
      raise Hyacinth::Exceptions::DigitalObjectNotFoundError, "Couldn't find DigitalObject with pid #{pid}"
    end

    # Retry after Fedora timeouts / unreachable host
    fobj = nil
    Retriable.retriable on: [RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH], tries: NUM_FEDORA_RETRY_ATTEMPTS, base_interval: DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS do
      fobj = ActiveFedora::Base.find(pid)
    end
    
    digital_object = DigitalObject::Base.get_class_for_fedora_object(fobj).new()
    digital_object.init_from_digital_object_record_and_fedora_object(digital_object_record, fobj)
    return digital_object
  end
  
  # Like self.find(), but returns nil when a DigitalObject isn't found instead of raising an error
  def self.find_by_pid(pid)
    begin
      return self.find(pid)
    rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
      return nil
    end
  end
  
  def self.find_by_pid_or_identifier(pid_or_identifier)
    return self.find_by_pid(pid) || self.find_by_pid(Cul::Hydra::RisearchMembers.get_pid_for_identifier(pid_or_identifier))
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
    if @project.blank?
      raise 'A project is required.'
    else
      return @project.get_enabled_dynamic_fields(self.digital_object_type)
    end
  end

  def save
    if self.valid?
      DigitalObjectRecord.transaction do
        if self.new_record?
          @fedora_object = self.get_new_fedora_object
          @db_record.pid = @fedora_object.pid
        else
          # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
          @db_record.lock! # Within the established transaction, lock on this object's row.  Remember: "lock!" also reloads object data from the db, so perform all @db_record modifications AFTER this call.
        end
        set_created_and_updated_data_from_db_record
        set_fedora_hyacinth_ds_data
        set_fedora_project_and_publisher_relationships
        set_fedora_object_state
        set_fedora_object_dc_type
        set_fedora_object_dc_identifiers
        set_fedora_object_dc_title_and_label

        set_fedora_parent_digital_object_pid_relationships if parent_digital_object_pids_changed?
        set_fedora_obsolete_parent_digital_object_pid_relationships if obsolete_parent_digital_object_pids_changed?
        
        run_post_validation_pre_save_logic()
        
        @db_record.save! # Save timestamps + updates to modifed_by, etc.

        # Retry after Fedora timeouts / unreachable host
        Retriable.retriable on: [RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH], tries: NUM_FEDORA_RETRY_ATTEMPTS, base_interval: DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS do
          @fedora_object.save
        end

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
                @errors.add(:parent_digital_objects, parent_obj.errors)
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
              new_parent_obj.add_ordered_child_digital_object(self)
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
  
  def run_post_validation_pre_save_logic
    # This method is intended to be overridden by DigitalObject::Base child classes
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

      struct_ds = Cul::Hydra::Datastreams::StructMetadata.new(nil, 'structMetadata', label:'Sequence', type:'logical')
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

    # Retry after Fedora timeouts / unreachable host
    Retriable.retriable on: [RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH], tries: NUM_FEDORA_RETRY_ATTEMPTS, base_interval: DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS do
      @fedora_object.save
    end

    return false if @errors.present?
      
    # Tell external publish targets to reindex this object
    self.publish_targets.each do |publish_target|
      if publish_target.publish_url.present?
      
        api_key = publish_target.api_key
        json_response = JSON(RestClient.post publish_target.publish_url, {pid: self.pid, api_key: api_key})
        
        unless json_response['success'] && json_response['success'].to_s == 'true'
          @errors.add(:publish_target, 'Error encountered while publishing to ' + publish_target.display_label)
        end
        
      end
    end
    
    return @errors.blank?
    
  end

  def next_pid
    self.project.next_pid
  end

  def self.valid_dc_types
    return self::VALID_DC_TYPES
  end

  def allowed_publish_targets
    return project.publish_targets
  end
  
  def self.titles_for_pids(pids, user_for_access)
  
    pids_to_titles = {}
    
    if pids.present?
      search_response = DigitalObject::Base.search(
        {
          'pids' => pids,
          'fl' => 'pid,title_ssm',
          'per_page' => 99999
        },
        false,
        user_for_access
      )
      if search_response['results'].present?
        search_response['results'].each do |result|
          pids_to_titles[result['pid']] = result['title_ssm'].first
        end
      end
    end
    
    return pids_to_titles
  end

  ######################
  # JSON Serialization #
  ######################

  # JSON representation
  def as_json(options={})
    return {
      pid: self.pid,
      identifiers: self.identifiers,
      title: self.get_title,
      state: @fedora_object ? @fedora_object.state : 'A',
      dc_type: self.dc_type,
      project: self.project,
      publish_targets: self.publish_targets.each{|pub| {string_key: pub.string_key, pid: pub.pid} },
      digital_object_type: { string_key: self.digital_object_type.string_key, display_label: self.digital_object_type.display_label },
      dynamic_field_data: @dynamic_field_data,
      ordered_child_digital_objects: self.ordered_child_digital_object_pids.map{|the_pid|{pid: the_pid}},
      parent_digital_objects: self.parent_digital_object_pids.map{|the_pid|{pid: the_pid}}
    }

  end

end
