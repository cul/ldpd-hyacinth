module DigitalObject::Validation
  extend ActiveSupport::Concern

  VALID_STATES = ['A', 'I', 'D'] # These are based on Fedora values: Active, Inactive and Deleted
  
  # Require the following methods for use with ActiveModel::Errors
  
  included do
    extend ActiveModel::Naming
  end
  
  class_methods do
    def human_attribute_name(attr, options = {})
      attr
    end
  
    def lookup_ancestors
      [self]
    end
  end
  
  def read_attribute_for_validation(attr)
    send(attr)
  end
  
  # Our other method continue below

  def valid?
    @errors.clear
    self.validate
    return @errors.blank?
  end
  
  def validate
    # DigitalObjects MUST have a sort title (though a non-sort portion of the title is not required)
    # ...except if this is a new Asset, since a missing title on a new asset means that we will use
    # the attached file name as the title later in the save process.
    unless @dynamic_field_data['title'] && @dynamic_field_data['title'][0] && @dynamic_field_data['title'][0]['title_sort_portion'].present?
      unless self.new_record? && self.is_a?(DigitalObject::Asset)
        @errors.add(:title_sort_portion, 'Every Digital Object must have a Title -> Sort Portion')
      end
    end

    # State must be among VALID_STATES
    unless VALID_STATES.include?(self.state)
      @errors.add(:state, 'Must be one of: ' + VALID_STATES.join(', '))
    end

    # State cannot be set to 'D' if this object has children
    if self.state == 'D' && self.ordered_child_digital_object_pids.length > 0
      errors.add(:destroy, 'Cannot set Digital Object as deleted because it has children.  Detach or delete all children first, then try deleting again.')
    end
    
    # All DigitalObject must have a @fedora_object with a dc_type within its set of VALID_DC_TYPES
    unless self.class.valid_dc_types.include?(self.dc_type)
      @errors.add(:dc_type, 'Must be one of: ' + self.class.valid_dc_types.join(', '))
    end

    # Exactly one project is required
    if self.project.present?
      
      enabled_dynamic_fields = self.get_enabled_dynamic_fields
      flattened_dynamic_field_data_without_blank_fields = get_flattened_dynamic_field_data(true)
      #flattened_dynamic_field_data_with_blank_fields = get_flattened_dynamic_field_data()
  
      # Validate the presence of required fields.
      # If a field is required, it must appear at least once in the dynamic_field_data
  
      required_dynamic_field_string_keys_to_dynamic_fields = {}
      enabled_dynamic_fields.each {|enabled_df|
        required_dynamic_field_string_keys_to_dynamic_fields[enabled_df.dynamic_field.string_key] = enabled_df.dynamic_field if enabled_df.required
      }
      if required_dynamic_field_string_keys_to_dynamic_fields.length > 0
        required_dynamic_field_string_keys_to_dynamic_fields.each{|string_key, dynamic_field|
          @errors.add(string_key + '.0', 'Missing required field: ' + dynamic_field.parent_dynamic_field_group.display_label + ' -> ' + dynamic_field.display_label) unless flattened_dynamic_field_data_without_blank_fields.has_key?(string_key)
        }
      end
      
    else
      @errors.add(:project, 'Must have a project')
    end

    # Note: No longer validating date field values because dates aren't always numeric/consistent (i.e. "uuuu" for undated values) and we need to support import for incorrectly formatted values
    #date_fields = get_enabled_dynamic_fields.map{|enabled_dynamic_field| enabled_dynamic_field.dynamic_field}.select{|dynamic_field| dynamic_field.dynamic_field_type == DynamicField::Type::DATE}
    #if date_fields.present?
    #  counter = 0
    #  date_fields.each {|date_field|
    #    counter = 0
    #    if flattened_dynamic_field_data_with_blank_fields.has_key?(date_field.string_key)
    #      flattened_dynamic_field_data_with_blank_fields[date_field.string_key].each {|value|
    #        # Date fields must match the expected ISO-8601 regex (YYYY, YYYY-MM or YYYY-MM-DD)
    #        unless value.blank? || value =~ /\A-*\d{4}\z/ || value =~ /\A-*\d{4}-\d{2}\z/ || value =~ /\A-*\d{4}-\d{2}-\d{2}\z/
    #          @errors.add(date_field.string_key + '.' + counter.to_s, 'Invalid date format: ' + date_field.parent_dynamic_field_group.display_label + ' -> ' + date_field.display_label + '.  Must be YYYY, YYYY-MM or YYYY-MM-DD.')
    #        end
    #        counter += 1
    #      }
    #    end
    #  }
    #end

    return @errors.blank?
  end
  


end
