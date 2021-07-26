# frozen_string_literal: true

module DigitalObject::EnabledDynamicFieldsValidations
  # Returns any errors related to project level validations.
  #
  # @return [String] if there are errors
  # @return [] if there are no errors
  def enabled_field_errors(digital_object, data)
    errors = []
    data_dynamic_field_paths = []

    data.each do |df_group, children|
      data_dynamic_field_paths = collect_field_paths(df_group, children, data_dynamic_field_paths)
    end

    enabled_dynamic_fields = EnabledDynamicField.where(project: digital_object.primary_project, digital_object_type: digital_object.digital_object_type).includes(:dynamic_field)

    enabled_dynamic_field_paths = enabled_dynamic_fields.map { |edf| edf.dynamic_field.path }

    data_dynamic_field_paths.each { |dfp| errors << [dfp, 'field must be enabled'] unless enabled_dynamic_field_paths.include? dfp }

    required_dynamic_field_paths = enabled_dynamic_fields.select(&:required).map { |edf| edf.dynamic_field.path }

    required_dynamic_field_paths.each { |rdfp| errors << [rdfp, 'is required'] unless data_dynamic_field_paths.include? rdfp }

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
