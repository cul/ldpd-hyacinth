class DigitalObject::PublishTarget < DigitalObject::Base
  VALID_DC_TYPES = ['Publish Target']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'publish_target'
  PUBLISH_TARGET_DATA_KEY = 'publish_target_data'

  PUBLISH_TARGET_DATA_FIELDS = ['string_key', 'publish_url', 'api_key', 'representative_image_pid', 'short_title', 'short_description', 'full_description', 'restricted', 'slug', 'site_url'].freeze
  REQUIRED_PUBLISH_TARGET_DATA_FIELDS = ['string_key'].freeze

  def initialize
    super
    self.dc_type ||= VALID_DC_TYPES.first

    @publish_target_data = {}
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    Concept.new(pid: next_pid)
  end

  def load_fedora_hyacinth_ds_data_from_fedora_object!
    super
    hyacinth_data = fedora_hyacinth_ds_data
    @publish_target_data = hyacinth_data.fetch(PUBLISH_TARGET_DATA_KEY, {})
  end

  # Overriding base behavior to also include publish_target_data
  def data_for_hyacinth_ds
    data = super
    data[PUBLISH_TARGET_DATA_KEY] = Marshal.load(Marshal.dump(@publish_target_data))
    data
  end

  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    super(digital_object_data, merge_dynamic_fields)
    return if digital_object_data['publish_target_data'].blank?
    @publish_target_data.merge!(digital_object_data['publish_target_data'])
    @publish_target_data['restricted'] = (@publish_target_data['restricted'].to_s.downcase == 'true')
  end

  def run_custom_validations
    if (@publish_target_data.keys - PUBLISH_TARGET_DATA_FIELDS).length > 0
      @errors.add(:publish_target_data, "Invalid publish_target_data fields: #{(@publish_target_data.keys - PUBLISH_TARGET_DATA_FIELDS).join(', ')}")
    end

    REQUIRED_PUBLISH_TARGET_DATA_FIELDS.each do |publish_target_data_field|
      @errors.add(:publish_target_data, "Missing required publish_target_data field: #{publish_target_data_field}") if @publish_target_data[publish_target_data_field].blank?
    end
  end

  def before_save
    super
    @publish_target_data['string_key'] = 'change-this-' + SecureRandom.uuid if @publish_target_data['string_key'].blank?
  end

  def before_publish
    # TODO: rewrite with ActiveRecord::Callbacks
    super

    # Serizlize publish data to Fedora
    if publish_target_field('representative_image_pid').present?
      @fedora_object.representative_image = 'info:fedora/' + publish_target_field('representative_image_pid')
    else
      @fedora_object.representative_image = nil
    end
    @fedora_object.short_title = publish_target_field('short_title').strip
    @fedora_object.abstract = publish_target_field('short_description').strip
    @fedora_object.description = publish_target_field('full_description').strip
    @fedora_object.restriction = publish_target_field('restricted') ? 'Onsite' : nil
    @fedora_object.slug = publish_target_field('slug').strip
    @fedora_object.source = publish_target_field('site_url').present? ? publish_target_field('site_url').strip : nil
  end

  def publish_target_field(field_name)
    raise InvalidPublishTargetField, 'Invalid publish target field: ' + field_name unless PUBLISH_TARGET_DATA_FIELDS.include?(field_name)
    @publish_target_data[field_name]
  end

  def self.all_pids
    search_results = search(
      {
        'fl' => 'pid',
        'fq' => { 'hyacinth_type_sim' => [{ 'equals' => 'publish_target' }] },
        'per_page' => 99_999
      },
      nil,
      {}
    )
    (search_results['results'].present? ? search_results['results'].map { |result| result['pid'] } : [])
  end

  def self.find_by_string_key(string_key)
    search_results = search(
      {
        'fl' => 'pid',
        'fq' => { 'publish_target_string_key_sim' => [{ 'equals' => string_key }] }
      },
      nil,
      {}
    )
    (search_results['results'].present? ? DigitalObject::Base.find(search_results['results'].first['pid']) : nil)
  end

  # Returns a minimal set of publish target data (pid, string_key and title), generally used by Groups, Items or Assets
  def self.basic_publish_target_data_from_solr(publish_target_pids)
    return [] if publish_target_pids.blank?

    search_results = search(
      {
        'fl' => 'pid, title_ssm, digital_object_data_ts',
        'pids' => publish_target_pids
      },
      nil,
      {}
    )
    return [] unless search_results['results'].present?

    search_results['results'].map do |publish_target_solr_doc|
      digital_object_data = JSON.parse(publish_target_solr_doc.fetch('digital_object_data_ts'))
      {
        'pid' => publish_target_solr_doc['pid'],
        'display_label' => publish_target_solr_doc['title_ssm'].first,
        'string_key' => digital_object_data.fetch('publish_target_data', {}).present? ? JSON.parse(publish_target_solr_doc['digital_object_data_ts'])['publish_target_data']['string_key'] : ''
      }
    end
  end

  def unpublish_digital_object(digital_object, do_ezid_update)
    response = RestClient.delete(
      publish_target_field('publish_url') + '/' + digital_object.pid,
      Authorization: "Token token=#{publish_target_field('api_key')}"
    )
    if do_ezid_update && !digital_object.doi.blank?
      # We need to change the state of this ezid to :unavailable
      # PSEUDO CODE
      # begin - rescue around the following call, rescue Hyacinth::Exceptions::DataciteError
      # Question: What to do if above exception is recued/caught?
      success = digital_object.change_doi_status_to_unavailable
      digital_object.errors.add(:ezid_response, "An error occurred while attempting to set this digital object's ezid status to 'unavailable'.") unless success
    end
    response
  end

  def publish_digital_object(digital_object, do_ezid_update)
    response = RestClient.put(
      publish_target_field('publish_url') + '/' + digital_object.pid,
      {},
      { Authorization: "Token token=#{publish_target_field('api_key')}" }
    )
    if do_ezid_update && response.code == 200 && response.headers[:location].present?
      # By this point, all records should have an ezid. Let's update the status of
      # that ezid to :public, and send the latest published_object_url in case it changed.
      # PSEUDO CODE
      # begin - rescue around the following call, rescue Hyacinth::Exceptions::DataciteError
      # Question: What to do if above exception is recued/caught?
      unless digital_object.update_doi_metadata(response.headers[:location])
        @errors.add(:ezid_response, "An error occurred while attempting to updated the ezid doi for this object.")
      end
    end
    response
  end

  def to_solr
    doc = super
    doc['publish_target_string_key_sim'] = @publish_target_data['string_key']
    doc
  end

  # JSON representation
  def as_json(options = {})
    json = super(options)
    json['publish_target_data'] = @publish_target_data
    json
  end
end
