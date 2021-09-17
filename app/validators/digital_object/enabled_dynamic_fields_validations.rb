# frozen_string_literal: true

module DigitalObject::EnabledDynamicFieldsValidations
  # Returns any errors related to project-and-digital_object_type based enabled field validations.
  # @param project [Project] Project that should be considered when determining which fields are enabled.
  # @param digital_object_type [String] Digital object type that should be considered when determining which fields are enabled.
  # @return [Array<Array<String, String>>] A list of errors of the format [['error path', 'error message']]
  def enabled_field_errors(project, digital_object_type, dynamic_field_data)
    errors = []
    field_paths_present_in_data = extract_dynamic_field_data_field_paths(dynamic_field_data)
    enabled_dynamic_fields = EnabledDynamicField.where(project: project, digital_object_type: digital_object_type).includes(:dynamic_field)
    enabled_dynamic_field_paths = enabled_dynamic_fields.map { |edf| edf.dynamic_field.path }
    (field_paths_present_in_data - enabled_dynamic_field_paths).each do |field_that_needs_to_be_enabled|
      errors << [field_that_needs_to_be_enabled, 'field must be enabled']
    end

    required_dynamic_field_paths = enabled_dynamic_fields.select(&:required).map { |edf| edf.dynamic_field.path }
    (required_dynamic_field_paths - field_paths_present_in_data).each do |missing_required_field_path|
      errors << [missing_required_field_path, 'is required']
    end

    errors
  end

  def extract_dynamic_field_data_field_paths(data, current_path = '', paths = [])
    data.each do |key, value|
      if value.is_a?(Array)
        # Key corresponds to a dynamic field group
        value.each do |dfg_value|
          extract_dynamic_field_data_field_paths(dfg_value, "#{current_path}#{key}/", paths)
        end
      else
        # Key corresponds to a dynamic field
        paths << "#{current_path}#{key}"
      end
    end

    paths
  end
end
