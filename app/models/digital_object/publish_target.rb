class DigitalObject::PublishTarget < DigitalObject::Base
  VALID_DC_TYPES = ['Publish Target']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'publish_target'
  DIGITAL_OBJECT_DATA_KEY = 'publish_target_data'

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
    @publish_target_data = hyacinth_data.fetch(DIGITAL_OBJECT_DATA_KEY, {})
  end

  # Overriding base behavior to also include publish_target_data
  def data_for_hyacinth_ds
    data = super
    data[DIGITAL_OBJECT_DATA_KEY] = Marshal.load(Marshal.dump(@publish_target_data))
    data
  end

  def set_digital_object_data(digital_object_data, merge_dynamic_fields)
    super(digital_object_data, merge_dynamic_fields)
    return if digital_object_data['publish_target_data'].blank?
    @publish_target_data = digital_object_data['publish_target_data']
  end

  def run_custom_validations
    if (@publish_target_data.keys - PUBLISH_TARGET_DATA_FIELDS).length > 0
      @errors.add(:publish_target_data, "Invalid publish_target_data fields: #{(@publish_target_data.keys - PUBLISH_TARGET_DATA_FIELDS).join(', ')}")
    end

    REQUIRED_PUBLISH_TARGET_DATA_FIELDS.each do |publish_target_data_field|
      @errors.add(:publish_target_data, "Missing required publish_target_data field: #{publish_target_data_field}") if @publish_target_data[publish_target_data_field].blank?
    end
  end

  def before_publish
    # TODO: rewrite with ActiveRecord::Callbacks
    super

    # Serizlize publish data to Fedora

    # ['string_key', 'publish_url', 'api_key', 'representative_image_pid', 'short_title', 'short_description', 'full_description', 'restricted', 'slug', 'site_url']

    # string_key -> ???
    # publish_url -> [Hyacinth Only, no need to serialize]
    # api_key -> [Hyacinth Only, no need to serialize]
    # representative_image_pid -> :foaf_thumbnail -> GenericResource PID
    # short_description -> :abstract -> RELS-EXT
    # full_description -> :description -> publishTargetDescription
    # project_facet_value -> ???
    # site_url -> ???
  end

  # JSON representation
  def as_json(options = {})
    json = super(options)
    json['publish_target_data'] = @publish_target_data
    json
  end
end
