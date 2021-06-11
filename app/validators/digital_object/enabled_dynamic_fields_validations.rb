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

  def check_required_fields(dynamic_field_paths, digital_object, errors)
    required_enabled_fields = EnabledDynamicField.where(project: digital_object.primary_project,
                                  digital_object_type: digital_object.digital_object_type, required: true)

    required_enabled_fields.each do |enabled_field|
      errors.concat ['is required'].map { |i| [enabled_field.dynamic_field.path, i] } unless dynamic_field_paths.include?(enabled_field.dynamic_field.path)
    end

    errors
  end

  def collect_field_paths(df_group, children, df_paths)
    children.each do |child|
      child.each do |df_name, value|
        df_paths << "#{df_group}/#{df_name}" if value
      end
    end
    df_paths
  end
end
