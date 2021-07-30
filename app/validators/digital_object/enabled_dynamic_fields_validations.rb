# frozen_string_literal: true

module DigitalObject::EnabledDynamicFieldsValidations
  # Returns any errors related to project-and-digital_object_type based enabled field validations.
  # @param project [Project] Project that should be considered when determining which fields are enabled.
  # @param digital_object_type [String] Digital object type that should be considered when determining which fields are enabled.
  # @return [Array<Array<String, String>>] A list of errors of the format [['error path', 'error message']]
  def enabled_field_errors(project, digital_object_type, data)
    errors = []
    data_dynamic_field_paths = []

    data.each { |df_group, children| data_dynamic_field_paths = collect_field_paths(df_group, children, data_dynamic_field_paths) }

    enabled_dynamic_fields = EnabledDynamicField.where(project: project, digital_object_type: digital_object_type).includes(:dynamic_field)

    enabled_dynamic_field_paths = enabled_dynamic_fields.map { |edf| edf.dynamic_field.path }
    (data_dynamic_field_paths - enabled_dynamic_field_paths).each do |field_that_needs_to_be_enabled|
      errors << [field_that_needs_to_be_enabled, 'field must be enabled']
    end

    required_dynamic_field_paths = enabled_dynamic_fields.select(&:required).map { |edf| edf.dynamic_field.path }
    (required_dynamic_field_paths - data_dynamic_field_paths).each do |missing_required_field_path|
      errors << [missing_required_field_path, 'is required']
    end

    errors
  end

  def collect_field_paths(df_group, children, df_paths)
    children.each do |child|
      child.each do |df_name, value|
        df_paths << construct_path(df_group, df_name, value) unless value.nil?
      end
    end
    df_paths
  end

  def construct_path(parent_path, field_name, value)
    path = "#{parent_path}/#{field_name}"
    if value.is_a?(Array)
      subfields = value[0]
      subfields.each do |name, val|
        path = construct_path(path, name, val)
      end
    end
    path
  end
end
