# frozen_string_literal: true

module DigitalObject::EnabledDynamicFieldsValidations
  # Returns any errors related to project level validations.
  #
  # @return [String] if there are errors
  # @return false if there are no errors
  def enabled_field_errors(digital_object, data)
    errors = []
    dynamic_field_paths = []
    data.each do |df_group, children|
      dynamic_field_paths = collect_field_paths(df_group, children, dynamic_field_paths)
      dynamic_field_paths.each do |dynamic_field_path|
        if (e = not_enabled?(dynamic_field_path, digital_object))
          errors.concat e.map { |i| [dynamic_field_path, i] }
        end
      end
    end

    errors = check_required_fields(dynamic_field_paths, digital_object, errors)

    errors
  end

  def not_enabled?(dynamic_field_path, digital_object)
    no_match = true
    dynamic_field = DynamicField.find_by(path: dynamic_field_path)
    if dynamic_field && EnabledDynamicField.where(dynamic_field: dynamic_field.id,
                                project: digital_object.primary_project,
                                digital_object_type: digital_object.digital_object_type).first
      no_match = false
    end
    return ['field must be enabled'] if no_match
    false
  end

  # For the given project and digital_object type, checks the given present_dynamic_field_paths list
  # to see if it contains all of the required fields.
  #
  # @param project [Project] A project.
  # @param digital_object_type [String] A digital object type.
  # @param present_dynamic_field_paths [Array<String>] An array of present dynamic field paths to check against a list of required paths.
  # @return [Array<Array<String>>] An array errors of the format: [['field name', 'error message], ['field name', 'error message]]
  def check_missing_required_fields(project, digital_object_type, present_dynamic_field_paths)
    required_field_paths = DynamicField.where(
      id: EnabledDynamicField.where(
        project: project, digital_object_type: digital_object_type, required: true
      ).pluck(:dynamic_field_id)
    ).pluck(:path)

    [required_field_paths - present_dynamic_field_paths].each do |missing_required_field_path|
      [missing_required_field_path, 'is required']
    end
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
