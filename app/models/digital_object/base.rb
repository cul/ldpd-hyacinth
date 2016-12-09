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
  include DigitalObject::Data
  include DigitalObject::Ezid

  NUM_FEDORA_RETRY_ATTEMPTS = 3
  DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS = 5
  RETRY_OPTIONS = { on: [RestClient::RequestTimeout, RestClient::Unauthorized, Errno::EHOSTUNREACH], tries: NUM_FEDORA_RETRY_ATTEMPTS, base_interval: DELAY_IN_SECONDS_BETWEEN_FEDORA_RETRY_ATTEMPTS }

  # For ActiveModel::Dirty
  define_attribute_methods :parent_digital_object_pids, :obsolete_parent_digital_object_pids, :ordered_child_digital_object_pids

  attr_accessor :project, :publish_target_pids, :identifiers, :created_by, :updated_by, :state, :dc_type, :ordered_child_digital_object_pids, :publish_after_save, :ezid_doi
  attr_reader :errors, :fedora_object, :parent_digital_object_pids

  delegate :created_at, :new_record?, :updated_at, to: :@db_record
  delegate :pid, to: :@fedora_object, allow_nil: true
  delegate :next_pid, to: :project

  VALID_DC_TYPES = [] # There are no valid dc types for DigitalObject::Base

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
    @state = 'A'
    @errors = ActiveModel::Errors.new(self)
    @publish_after_save = false
    @ezid_doi = nil
  end

  def init_from_digital_object_record_and_fedora_object(digital_object_record, fedora_obj)
    @publish_after_save = false
    @db_record = digital_object_record
    @fedora_object = fedora_obj

    # For existing records, we always lock on @db_record during Fedora reads/writes (and wrap in a transaction)
    @db_record.with_lock do # with_lock creates a transaction and locks on the called object's row
      load_data_from_sources
    end
  end

  def load_data_from_sources
    load_created_and_updated_data_from_db_record!
    load_parent_digital_object_pid_relationships_from_fedora_object!
    load_state_from_fedora_object!
    load_dc_type_from_fedora_object!
    load_dc_identifiers_from_fedora_object!
    load_project_and_publisher_relationships_from_fedora_object!
    load_fedora_hyacinth_ds_data_from_fedora_object!
  end

  def reset_data_attributes_before_assignment(digital_object_data)
    @ordered_child_digital_object_pids = [] unless digital_object_data['ordered_child_digital_objects'].blank?
    # Do not clear old values if this is a new record because we may be preserving values from Fedora upon import
    return if self.new_record?
    # Only clear data before assignment if a value has been supplied
    @parent_digital_object_pids = [] if digital_object_data.key?('parent_digital_objects')
    @identifiers = [] if digital_object_data.key?('identifiers')
    @publish_target_pids = [] if digital_object_data.key?('publish_targets')
  end

  # Updates the DigitalObject with the given digital_object_data
  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    # If a user sets the publish field to "true", set the publish_after_save flag
    @publish_after_save = digital_object_data['publish'] =~ /true/i

    create_or_validate_pid_from_data(pid, digital_object_data)

    reset_data_attributes_before_assignment(digital_object_data)

    # Parent Digital Objects (PID or Identifier)
    parent_digital_objects_from_data(digital_object_data) { |digital_object| add_parent_digital_object(digital_object) }

    # Identifiers (multiple)
    @identifiers += digital_object_data['identifiers'] if digital_object_data['identifiers']

    # Project (only one) -- Only allow setting this if this DigitalObject is a new record
    self.project = project_from_data(digital_object_data) if self.new_record?

    # Publish Targets (multiple)
    publish_target_pids_from_data(digital_object_data) { |publish_target_pid| @publish_target_pids.push(publish_target_pid) }

    # Ordered child Digital Objects (PID or Identifier)
    ordered_child_digital_objects_from_data(digital_object_data) { |digital_object| add_ordered_child_digital_object(digital_object) }

    set_dynamic_fields_from_data(digital_object_data, merge_dynamic_fields)

    # If this is an Asset, and its title is blank after dynamic field data
    # is applied, use the DEFAULT_ASSET_NAME. This allows validation to complete,
    # and the title will be later inferred from the filename during the upload step.
    set_title('', DigitalObject::Asset::DEFAULT_ASSET_NAME) if self.is_a?(DigitalObject::Asset) && get_title.blank?
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
    return if parent_digital_object.nil?

    new_parent_digital_object_pid = parent_digital_object.pid

    unless @parent_digital_object_pids.include?(new_parent_digital_object_pid)
      parent_digital_object_pids_will_change!
      @parent_digital_object_pids << new_parent_digital_object_pid
    end

    return unless @obsolete_parent_digital_object_pids.include?(new_parent_digital_object_pid)

    obsolete_parent_digital_object_pids_will_change!
    @obsolete_parent_digital_object_pids.delete(new_parent_digital_object_pid)
  end

  def remove_parent_digital_object(parent)
    parent_pid = parent.pid
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

  def before_publish
    # TODO: rewrite with ActiveRecord::Callbacks
    save_datastreams
  end

  def publish
    before_publish

    # Save withg retry after Fedora timeouts / unreachable host
    Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
      @fedora_object.save(update_index: false)
    end

    inactive_publish_target_pids = allowed_publish_targets.map { |pub_target_data| pub_target_data[:pid] } - publish_target_pids
    active_publish_target_pids = publish_target_pids

    # Make sure to unpublish from INACTIVE publish targets before doing publishing to active
    # publish targets, just in case multiple publish targets have the same publish URL
    (inactive_publish_target_pids + active_publish_target_pids).each do |publish_target_pid|
      do_unpublish = inactive_publish_target_pids.include?(publish_target_pid)
      publish_target = DigitalObject::Base.find(publish_target_pid)

      begin
        send_request_to_publish_target_url(do_unpublish ? :unpublish : :publish, publish_target.publish_target_field('publish_url'), pid, publish_target.publish_target_field('api_key'))
      rescue RestClient::Unauthorized
        @errors.add(:publish_target, "Not authorized to #{do_unpublish ? 'unpublish' : 'publish'} to #{publish_target.get_title}. Check credentials.")
      rescue RestClient::NotFound
        @errors.add(:publish_target, "404 Not Found received for Publish Target URL: #{publish_target.publish_target_field('publish_url')}")
      end
    end

    @errors.blank?
  end

  def send_request_to_publish_target_url(publish_action, publish_url_prefix, pid, api_key)
    publish_url = publish_url_prefix + '/' + pid
    if publish_action == :unpublish
      response = RestClient.delete(
        publish_url,
        Authorization: "Token token=#{api_key}"
      )
      # unless @ezid_doi.blank?
      #  # We need to change the state of this ezid to :unavailable
      #  ezid_response = change_doi_status_to_unavailable
      #  @errors.add(:ezid_response, "An error occurred while attempting to set this digital object's ezid status to 'unavailable'.")
      # end
    elsif publish_action == :publish
      response = RestClient.put(
        publish_url,
        {},
        Authorization: "Token token=#{api_key}"
      )
      # if response.code == 200 && response.headers[:location].present?
      #   published_object_url = response.headers[:location]
      #   if @ezid_doi.blank?
      #     # If this record has no ezid, that means that we're publishing it for the first time.
      #     # Mint ezid using
      #     mint_and_store_doi(Hyacinth::Ezid::Doi::IDENTIFIER_STATUS, published_object_url)
      #     # And now that we've stored the doi, save and re-publish this object
      #     # TODO: In the future we'll be queueing a re-publish instead of calling save && publish below
      #     save && publish
      #   else
      #     # This record already has an ezid.  Let's update the status of that ezid to :public.
      #     ezid_api_session = Hyacinth::Ezid::ApiSession.new(EZID[:user], EZID[:password])
      #     ezid_api_session.modify_identifier(@ezid_doi,
      #                               _status: Hyacinth::Ezid::Doi::IDENTIFIER_STATUS[:public])
      #   end
      # end
    end

    @errors.add(:publish_target, "Error encountered while #{do_unpublish ? 'unpublishing' : 'publishing'} to #{publish_target.get_title}") if response.code != 200
  end

  def self.valid_dc_types
    self::VALID_DC_TYPES
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

  def self.titles_for_pids(pids, user_for_access)
    pids_to_titles = {}

    if pids.present?
      search_response = DigitalObject::Base.search(
        {
          'pids' => pids,
          'fl' => 'pid,title_ssm',
          'per_page' => 99_999
        },
        user_for_access
      )
      if search_response['results'].present?
        search_response['results'].each do |result|
          pids_to_titles[result['pid']] = result['title_ssm'].first
        end
      end
    end

    pids_to_titles
  end
end
