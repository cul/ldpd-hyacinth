# frozen_string_literal: true

# TODO: Some of these method can be refactored to be used to validate dynamic field data and rights data.
class DigitalObject::RightsValidator < ActiveModel::Validator
  def validate(digital_object)
    if digital_object.is_a?(DigitalObject::Asset) || digital_object.is_a?(DigitalObject::Item)
      # Fetch dynamic field definitions for item_rights or asset_rights
      categories = DynamicFieldCategory.where(metadata_form: "#{digital_object.digital_object_type}_rights")
                                       .includes(dynamic_field_groups: [:dynamic_field_groups, :dynamic_fields])

      map = field_map(categories.collect_concat(&:dynamic_field_groups))

      # Check that all the values given have an appropriate field.
      check_data(digital_object, map, digital_object.rights)
    else
      digital_object.errors.add(:rights, "cannot be assigned for #{digital_object.digital_object_type}") unless digital_object.rights.blank?
    end
  end

  # Generates a map of dynamic fields groups and dynamic fields.
  def field_map(fields_or_groups)
    fields_or_groups.map { |field_or_group|
      if field_or_group.is_a? DynamicField
        [field_or_group.string_key, field_or_group.field_type]
      elsif field_or_group.is_a? DynamicFieldGroup
        [field_or_group.string_key, field_map(field_or_group.children)]
      end
    }.to_h
  end

  def check_data(digital_object, field_map, data, path = nil)
    data.each do |field_or_group_key, value|
      new_path = [path, field_or_group_key].compact.join('.')

      if field_map.key?(field_or_group_key)
        if value.is_a?(Array)
          reduced_field_map = field_map[field_or_group_key]

          if reduced_field_map.is_a?(Hash)
            value.each_with_index do |v, i|
              check_data(digital_object, reduced_field_map, v, "#{new_path}[#{i}]")
            end
          else
            digital_object.errors.add(:rights, "'#{new_path}' cannot be an array")
          end
        else
          field_type = field_map[field_or_group_key]
          if field_type.is_a?(String) # DynamicField
            digital_object.errors.add(:rights, "'#{new_path}' does not contain the correct value for a field of type #{field_type}") unless valid_field_value?(field_type, value)
          else
            digital_object.errors.add(:rights, "'#{new_path}' does contain data in the correct format.")
          end
        end
      else
        digital_object.errors.add(:rights, "'#{new_path}' is not a valid field")
      end
    end
  end

  # Check that the value given can be stored for the field_type given.
  # TODO: Some of these checks, particularly those for select, controlled_term and data are incomplete.
  def valid_field_value?(field_type, value)
    case field_type
    when DynamicField::Type::STRING, DynamicField::Type::TEXTAREA, DynamicField::Type::SELECT, DynamicField::Type::DATE
      return true if value.is_a?(String)
    when DynamicField::Type::BOOLEAN
      return true if value.is_a?(TrueClass) || value.is_a?(FalseClass)
    when DynamicField::Type::CONTROLLED_TERM
      return true if value.is_a?(Hash) # TODO: Need to do a more through check that this term exists and that the data is complete.
    when DynamicField::Type::INTEGER
      return true if value.is_a?(Integer)
    end

    false
  end
end
