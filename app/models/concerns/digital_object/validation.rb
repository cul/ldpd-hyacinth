module DigitalObject::Validation
  extend ActiveSupport::Concern

  VALID_STATES = ['A', 'I', 'D'] # These are based on Fedora values: Active, Inactive and Deleted
  FEDORA_VALID_PID_REGEX = /^([A-Za-z0-9]|-|\.)+:(([A-Za-z0-9])|-|\.|~|_|(%[0-9A-F]{2}))+$/

  included do
    extend ActiveModel::Naming # Required for use with ActiveModel::Errors
  end

  class_methods do
    # Required for use with ActiveModel::Errors
    def human_attribute_name(attr, _options = {})
      attr
    end

    # Required for use with ActiveModel::Errors
    def lookup_ancestors
      [self]
    end
  end

  # Required for use with ActiveModel::Errors
  def read_attribute_for_validation(attr)
    send(attr)
  end

  # Our other method continue below

  def valid?
    @errors.clear
    validate
  end

  def validate
    validate_title
    validate_state
    validate_dc_type
    validate_project_presence

    # Make sure that none of the identifiers conflict with the PID of another existing Fedora object
    @identifiers.each { |identifier| validate_identifier(identifier) }

    # validate allowed publish targets
    allowed_publish_target_pids = allowed_publish_targets.map { |pub_target_data| pub_target_data['pid'] }
    active_publish_target_pids = publish_target_pids

    # If any of the active publish targets aren't allowed by the project, notify the user
    active_publish_target_pids.each do |active_publish_target_pid|
      unless allowed_publish_target_pids.include?(active_publish_target_pid)
        publish_target = DigitalObject::Base.find(active_publish_target_pid)
        @errors.add(:publish_target, "Publish target #{publish_target.get_title} (#{publish_target.publish_target_field('string_key')} / #{publish_target.pid}) is not enabled for this project. You'll need to remove it or enable it.")
      end
    end

    run_custom_validations

    @errors.blank?
  end

  def validate_state
    # State must be among VALID_STATES
    unless VALID_STATES.include?(state)
      errors.add(:state, 'Must be one of: ' + VALID_STATES.join(', '))
    end

    # State cannot be set to 'D' if this object has children
    errors.add(
      :destroy,
      'Cannot set Digital Object as deleted because it has children.  Detach or delete all children first, then try deleting again.'
    ) if state == 'D' && ordered_child_digital_object_pids.length > 0
  end

  def validate_dc_type
    # All DigitalObject must have a @fedora_object with a dc_type within its set of VALID_DC_TYPES
    errors.add(:dc_type, "Is: #{dc_type}. Must be one of: #{self.class.valid_dc_types.join(', ')}") unless self.class.valid_dc_types.include?(dc_type)
  end

  def validate_project_presence
    # Exactly one project is required
    if project.present?
      validate_required_fields(get_flattened_dynamic_field_data(true))
    else
      errors.add(:project, 'Must have a project')
    end
  end

  def run_custom_validations
    # This method should be overwritten by subclasses of DigitalObject::Base if they have custom validations
  end

  def validate_title
    # DigitalObjects MUST have a sort title (though a non-sort portion of the title is not required)
    # ...except if this is a new Asset, since a missing title on a new asset means that we will use
    # the attached file name as the title later in the save process.
    valid_title = @dynamic_field_data['title']
    valid_title &&= @dynamic_field_data['title'][0]
    valid_title &&= @dynamic_field_data['title'][0]['title_sort_portion'].present?
    valid_title ||= (self.new_record? && self.is_a?(DigitalObject::Asset))

    @errors.add(:title_sort_portion, 'Every Digital Object must have a Title -> Sort Portion') unless valid_title
  end

  def validate_required_fields(flattened_dynamic_field_data)
    # Validate the presence of required fields.
    # If a field is required, it must appear at least once in the dynamic_field_data

    required_dynamic_fields = enabled_dynamic_fields.select(&:required)
    required_dynamic_field_string_keys_to_dynamic_fields = required_dynamic_fields.map { |enabled_df| [enabled_df.dynamic_field.string_key, enabled_df.dynamic_field] }.to_h

    required_dynamic_field_string_keys_to_dynamic_fields.each do |string_key, dynamic_field|
      @errors.add(string_key + '.0', 'Missing required field: ' + dynamic_field.parent_dynamic_field_group.display_label + ' -> ' + dynamic_field.display_label) unless flattened_dynamic_field_data.key?(string_key)
    end
  end

  def validate_identifier(identifier)
    invalid_identifier = identifier != pid
    invalid_identifier &&= identifier.match(FEDORA_VALID_PID_REGEX)
    invalid_identifier &&= ActiveFedora::Base.exists?(identifier)

    @errors.add(:identifier, "Cannot assign identifier #{identifier} because a Fedora object with this pid already exists.") if invalid_identifier
  end
end
