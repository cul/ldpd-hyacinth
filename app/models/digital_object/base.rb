class DigitalObject::Base
  include ActiveModel::Dirty
  include DigitalObject::IndexAndSearch
  include DigitalObject::Validation
  include DigitalObject::Fedora
  include DigitalObject::DigitalObjectRecord
  include DigitalObject::DynamicField
  include DigitalObject::XmlDatastreamRendering
  include DigitalObject::FinderMethods
  include DigitalObject::Persistence
  include DigitalObject::Serialization
  include DigitalObject::Publishing
  include DigitalObject::Data
  include DigitalObject::Datacite

  NUM_FEDORA_RETRY_ATTEMPTS = 3
  DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS = 5
  RETRY_OPTIONS = { on: [RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH], tries: NUM_FEDORA_RETRY_ATTEMPTS, base_interval: DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS }

  # For ActiveModel::Dirty
  define_attribute_methods :parent_digital_object_pids, :obsolete_parent_digital_object_pids, :ordered_child_digital_object_pids

  attr_accessor :project, :publish_target_pids, :identifiers, :created_by, :updated_by, :first_published_at, :state, :dc_type, :ordered_child_digital_object_pids, :publish_after_save, :mint_reserved_doi_before_save, :doi, :perform_derivative_processing
  attr_reader :errors, :fedora_object, :parent_digital_object_pids, :db_record

  delegate :created_at, :new_record?, :updated_at, :uuid, :data_file_path, to: :@db_record
  delegate :pid, to: :@fedora_object, allow_nil: true
  delegate :next_pid, to: :project

  VALID_DC_TYPES = [] # There are no valid dc types for DigitalObject::Base
  STATE_ACTIVE = 'A'
  STATE_INACTIVE = 'I' # We used to use this in Fedora, but Hyacinth doesn't assign objects a state of Inactive
  STATE_DELETED = 'D'

  def require_subclass_override!
    raise 'This method must be overridden by a subclass'
  end

  def initialize
    raise 'The DigitalObject::Base class cannot be instantiated.  You can only instantiate subclasses like DigitalObject::Item' if self.class == DigitalObject::Base
    @db_record = ::DigitalObjectRecord.new
    @fedora_object = nil
    @project = nil
    @publish_target_pids = []
    @identifiers = []
    @parent_digital_object_pids = []
    @obsolete_parent_digital_object_pids = []
    @ordered_child_digital_object_pids = []
    @dynamic_field_data = {}
    @state = STATE_ACTIVE
    @errors = ActiveModel::Errors.new(self)
    @publish_after_save = false
    @doi = nil
    @mint_reserved_doi_before_save = false
    # base object does not require derivative processing (but this will be overridden in Asset subclass)
    @perform_derivative_processing = false
  end

  def init_from_digital_object_record_and_fedora_object(digital_object_record, fedora_obj)
    @publish_after_save = false
    @db_record = digital_object_record
    @fedora_object = fedora_obj

    # We need to wrap the lock in a retry because concurrent background jobs on the same record can cause exceptions like 'Mysql2::Error: Lock wait timeout exceeded'
    Retriable.retriable(on: [Mysql2::Error], tries: 3, base_interval: 30) do
      # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
      @db_record.with_lock do # with_lock creates a transaction and locks on the called object's row
        load_data_from_sources
      end
    end
  end

  def load_data_from_sources
    load_data_from_db_record!
    load_parent_digital_object_pid_relationships_from_fedora_object!
    load_state_from_fedora_object!
    load_dc_type_from_fedora_object!
    load_dc_identifiers_from_fedora_object!
    load_ezid_from_fedora_object!
    load_project_and_publisher_relationships_from_fedora_object!
    load_fedora_hyacinth_ds_data_from_fedora_object!
  end

  def set_data_to_sources
    set_created_and_updated_data_from_db_record
    set_first_published_at
    set_perform_derivative_processing
    set_fedora_hyacinth_ds_data
    set_fedora_project_and_publisher_relationships
    set_fedora_object_state
    set_fedora_object_dc_type
    set_fedora_object_dc_identifiers
    set_fedora_object_dc_title_and_label
    set_fedora_object_ezid_doi

    set_fedora_parent_digital_object_pid_relationships if parent_digital_object_pids_changed?
    set_fedora_obsolete_parent_digital_object_pid_relationships if obsolete_parent_digital_object_pids_changed?
  end

  def reset_data_attributes_before_assignment(digital_object_data)
    # Do not clear old values if this is a new record because we may be preserving values from Fedora upon import
    return if self.new_record?

    @ordered_child_digital_object_pids = [] unless digital_object_data['ordered_child_digital_objects'].blank?
    # Only clear data before assignment if a value has been supplied
    if digital_object_data.key?('parent_digital_objects')
      @parent_digital_object_pids.map { |pid| remove_parent_digital_object_by_pid(pid) }
      @parent_digital_object_pids = []
    end

    @identifiers = [] if digital_object_data.key?('identifiers')
    @publish_target_pids = [] if digital_object_data.key?('publish_targets')
  end

  # Updates the DigitalObject with the given digital_object_data
  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    publish_after_save_from_data(digital_object_data)
    mint_reserved_doi_from_data(digital_object_data)

    create_or_validate_pid_from_data(pid, digital_object_data)

    reset_data_attributes_before_assignment(digital_object_data)

    # Parent Digital Objects (PID or Identifier)
    parent_digital_objects_from_data(digital_object_data) { |digital_object| add_parent_digital_object(digital_object) }

    # Identifiers (multiple)
    @identifiers += digital_object_data['identifiers'] if digital_object_data['identifiers']

    # Allow setting of doi if doi hasn't already been set
    @doi = digital_object_data['doi'] if @doi.blank? && digital_object_data['doi'].present?

    # Allow setting of first_published_at if the field isn't blank
    @first_published_at = digital_object_data['first_published'] if digital_object_data['first_published'].present?

    # Set perform_derivative_processing field if it has been provided
    if digital_object_data.key?('perform_derivative_processing') && digital_object_data['perform_derivative_processing'] != ''
      @perform_derivative_processing = digital_object_data['perform_derivative_processing'].to_s.downcase == 'true'
    end

    # Project (only one project is supported right now)
    self.project = project_from_data(digital_object_data) || self.project

    # Publish Targets (multiple)
    publish_target_pids_from_data(digital_object_data) { |publish_target_pid| @publish_target_pids.push(publish_target_pid) }

    # Ordered child Digital Objects (PID or Identifier)
    ordered_child_digital_objects_from_data(digital_object_data) { |digital_object| add_ordered_child_digital_object(digital_object) }

    set_dynamic_fields_from_data(digital_object_data, merge_dynamic_fields)
  end

  # Returns the primary title
  def get_title(opts = {})
    title = ''
    if @dynamic_field_data['title'] && @dynamic_field_data['title'].first && @dynamic_field_data['title'].first['title_non_sort_portion'].present?
      title += @dynamic_field_data['title'].first['title_non_sort_portion'] + ' '
    end
    title + get_sort_title(opts)
  end

  # Returns the sort portion of the primary title
  def get_sort_title(opts = {})
    sort_title = opts[:placeholder_if_blank] ? '[No Title]' : ''
    if @dynamic_field_data['title'] && @dynamic_field_data['title'].first && @dynamic_field_data['title'].first['title_sort_portion']
      sort_title = @dynamic_field_data['title'].first['title_sort_portion']
    end
    sort_title
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
    if parent_digital_object.nil?
      self.errors.add(:parent_digital_objects, "Tried to add a parent digital object that could not be found.")
      return
    end

    new_parent_digital_object_pid = parent_digital_object.pid

    unless @parent_digital_object_pids.include?(new_parent_digital_object_pid)
      parent_digital_object_pids_will_change!
      @parent_digital_object_pids << new_parent_digital_object_pid
    end

    return unless @obsolete_parent_digital_object_pids.include?(new_parent_digital_object_pid)

    obsolete_parent_digital_object_pids_will_change!
    @obsolete_parent_digital_object_pids.delete(new_parent_digital_object_pid)
  end

  def remove_parent_digital_object_by_pid(parent_pid)
    return unless @parent_digital_object_pids.include?(parent_pid)

    parent_digital_object_pids_will_change!
    obsolete_parent_digital_object_pids_will_change!
    deleted_pid = @parent_digital_object_pids.delete(parent_pid)
    @obsolete_parent_digital_object_pids << deleted_pid unless @obsolete_parent_digital_object_pids.include?(deleted_pid)
  end

  # This method is only required for when the ResourceIndex doesn't have immediate updates turned on
  def remove_ordered_child_digital_object_pid(digital_object_pid)
    return unless @ordered_child_digital_object_pids.include?(digital_object_pid)
    @ordered_child_digital_object_pids.delete(digital_object_pid)
  end

  # This method is only required for when the ResourceIndex doesn't have immediate updates turned on
  def add_ordered_child_digital_object(new_child)
    return if new_child.nil? || @ordered_child_digital_object_pids.include?(new_child.pid)

    @ordered_child_digital_object_pids << new_child.pid
  end

  def publish_after_save_from_data(digital_object_data)
    # If a user sets the publish field to "true", set the publish_after_save flag
    @publish_after_save = digital_object_data['publish'].to_s.match?(/true/i) if digital_object_data.key?('publish')
  end

  def mint_reserved_doi_from_data(digital_object_data)
    # If a user sets the mint_reserved_doi field to "true", set the mint_reserved_doi flag
    @mint_reserved_doi_before_save = digital_object_data['mint_reserved_doi'].to_s.match?(/true/i) if digital_object_data.key?('mint_reserved_doi')
  end

  # Getters

  def digital_object_type
    @digital_object_type ||= DigitalObjectType.find_by(string_key: self.class::DIGITAL_OBJECT_TYPE_STRING_KEY)
  end

  def enabled_dynamic_fields
    raise 'A project is required.' if @project.blank?

    @project.enabled_dynamic_fields_for_type(digital_object_type)
  end

  def run_post_validation_pre_save_logic
    # TODO: rewrite with ActiveRecord::Callbacks
    # This method is intended to be overridden by DigitalObject::Base child classes
  end

  def run_after_create_logic
    # TODO: rewrite with ActiveRecord::Callbacks
    # This method is intended to be overridden by DigitalObject::Base child classes
  end

  def run_after_save_logic
    # TODO: rewrite with ActiveRecord::Callbacks
    # This method is intended to be overridden by DigitalObject::Base child classes
  end

  def before_publish
    # TODO: rewrite with ActiveRecord::Callbacks
    save_datastreams
  end

  def self.valid_dc_types
    self::VALID_DC_TYPES
  end

  def audio_moving_image?
    false
  end

  def still_image?
    false
  end

  def allowed_publish_targets
    DigitalObject::PublishTarget.basic_publish_target_data_from_solr(project.enabled_publish_target_pids)
  end

  def publish_target_data
    DigitalObject::PublishTarget.basic_publish_target_data_from_solr(@publish_target_pids)
  end

  def publish_targets
    return [] if @publish_target_pids.blank?
    @publish_target_pids.map { |publish_target_pid| DigitalObject::Base.find(publish_target_pid) }
  end

  def self.title_for_pid(pid, user_for_access)
    titles_for_pids([pid], user_for_access).values.first
  end

  def self.titles_for_pids(pids, user_for_access)
    pids_to_titles = {}

    if pids.present?
      # Retrieve object data in chunks so that we don't exceed the solr max boolean clause limit
      # (since we're generating queries that OR together the list of given PIDs, and that generates a lot of clauses).
      chunk_size = 500
      pids.each_slice(chunk_size).each do |subset_of_pids|
        search_response = DigitalObject::Base.search({ 'pids' => subset_of_pids, 'fl' => 'pid,title_ss', 'per_page' => chunk_size }, user_for_access)
        if search_response['results'].present?
          search_response['results'].each do |result|
            pids_to_titles[result['pid']] = result['title_ss'].first
          end
        end
      end
    end

    pids_to_titles
  end


  def self.parent_pids_for_pid(pid, user_for_access)
    parent_pids_for_pids([pid], user_for_access).values.first
  end

  def self.parent_pids_for_pids(pids, user_for_access)
    pids_to_parent_pids = {}

    if pids.present?
      # Retrieve object data in chunks so that we don't exceed the solr max boolean clause limit
      # (since we're generating queries that OR together the list of given PIDs, and that generates a lot of clauses).
      chunk_size = 500
      pids.each_slice(chunk_size).each do |subset_of_pids|
        search_response = DigitalObject::Base.search({ 'pids' => subset_of_pids, 'fl' => 'pid,parent_digital_object_pids_sim', 'per_page' => chunk_size }, user_for_access)
        if search_response['results'].present?
          search_response['results'].each do |result|
            pids_to_parent_pids[result['pid']] = result['parent_digital_object_pids_sim']
          end
        end
      end
    end

    pids_to_parent_pids
  end
end
