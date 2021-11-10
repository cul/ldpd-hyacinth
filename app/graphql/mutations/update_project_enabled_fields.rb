# frozen_string_literal: true

class Mutations::UpdateProjectEnabledFields < Mutations::BaseMutation
  argument :project, Inputs::StringKey, "String key for project", required: true
  argument :digital_object_type, Enums::DigitalObjectTypeEnum, "digital object type", required: true
  argument(
    :enabled_dynamic_fields,
    [Inputs::EnabledDynamicFieldInput],
    "An array representing the new set of enabled dynamic fields for the object type in the given project, "\
    "or an empty array to remove all project enabled fields for the digital object type.",
    required: true
  )

  field :project_enabled_fields, [Types::EnabledDynamicFieldType], null: false
  field :user_errors, [Types::Errors::FieldedInput], null: true

  def resolve(project:, digital_object_type:, enabled_dynamic_fields:)
    # renaming variable locally for clarity
    enabled_dynamic_field_inputs = enabled_dynamic_fields

    # Ensure that the user initiating this update is allowed to do so for the given project
    project = Project.find_by!(project.to_h)
    ability.authorize! :update, project

    project_and_type_params = { project_id: project.id, digital_object_type: digital_object_type }
    errors = []

    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      currently_enabled_dynamic_fields = EnabledDynamicField.where(project_and_type_params).to_a
      dynamic_field_ids_for_currently_enabled_dynamic_fields = currently_enabled_dynamic_fields.map { |edf| edf.dynamic_field.id }
      dynamic_field_ids_for_new_enabled_dynamic_fields = enabled_dynamic_field_inputs.map { |edf_input| edf_input.dynamic_field.id.to_i }

      dynamic_field_ids_to_enable, dynamic_field_ids_to_disable, dynamic_field_ids_to_update =
        reconcile_enables_disables_updates(dynamic_field_ids_for_new_enabled_dynamic_fields, dynamic_field_ids_for_currently_enabled_dynamic_fields)

      EnabledDynamicField.transaction do
        # Perform disable actions
        # Note: Failures can occur here if someone is trying to disable a field that's in use for the project.
        EnabledDynamicField.includes(:dynamic_field).where(project_and_type_params.merge(dynamic_field_id: dynamic_field_ids_to_disable)).each do |edf|
          errors.concat(destroy_and_collect_errors(edf))
        end

        # Perform create actions
        enabled_dynamic_field_inputs.select { |edf_input| dynamic_field_ids_to_enable.include?(edf_input.dynamic_field.id.to_i) }.each do |edf_input|
          attributes = edf_input.to_h
          attributes.merge!(project_and_type_params)
          attributes[:dynamic_field_id] = attributes.delete(:dynamic_field).fetch(:id)&.to_i
          attributes[:field_sets] = attributes.delete(:field_sets)&.map { |fs| FieldSet.find(fs[:id].to_i) }
          errors.concat(create_and_collect_errors(attributes))
        end

        # Perform update actions
        enabled_dynamic_field_inputs.select { |edf_input| dynamic_field_ids_to_update.include?(edf_input.dynamic_field.id.to_i) }.each do |edf_input|
          attributes = edf_input.to_h
          dynamic_field_id = attributes.delete(:dynamic_field).fetch(:id)&.to_i
          attributes[:field_sets] = attributes.delete(:field_sets)&.map { |fs| FieldSet.find(fs[:id].to_i) }
          errors.concat(update_and_collect_errors(currently_enabled_dynamic_fields.find { |current_edf| current_edf.dynamic_field_id == dynamic_field_id }, attributes))
        end

        raise ActiveRecord::Rollback, "Rolling back because errors were encountered." if errors.present?
      end
    end

    format_response(EnabledDynamicField.where(project_and_type_params), errors)
  end

  def format_response(enabled_fields, errors)
    {
      project_enabled_fields: enabled_fields
    }.merge(
      errors.present? ? { user_errors: errors } : {}
    )
  end

  def collect_errors(errors, dynamic_field_path)
    collected_errors = []
    errors.messages.each do |_error_key, messages|
      messages.each do |message|
        collected_errors << { message: message, path: dynamic_field_path }
      end
    end
    collected_errors
  end

  def reconcile_enables_disables_updates(dynamic_field_ids_for_new_enabled_dynamic_fields, dynamic_field_ids_for_currently_enabled_dynamic_fields)
    dynamic_field_ids_to_enable = dynamic_field_ids_for_new_enabled_dynamic_fields - dynamic_field_ids_for_currently_enabled_dynamic_fields
    dynamic_field_ids_to_disable = dynamic_field_ids_for_currently_enabled_dynamic_fields - dynamic_field_ids_for_new_enabled_dynamic_fields
    dynamic_field_ids_to_update = dynamic_field_ids_for_currently_enabled_dynamic_fields - dynamic_field_ids_to_disable

    [dynamic_field_ids_to_enable, dynamic_field_ids_to_disable, dynamic_field_ids_to_update]
  end

  # Attempts to destroy the given enabled_dynamic_field and returns an array of errors added during
  # the destroy attempt, if there are any.  If there aren't any errors and the destroy operation was
  # successful, an empty array is returned.
  def destroy_and_collect_errors(enabled_dynamic_field)
    enabled_dynamic_field.destroy
    collect_errors(enabled_dynamic_field.errors, enabled_dynamic_field.dynamic_field.path.split('/'))
  end

  # Attempts to create an EnabledDynamicField from the given enabled_dynamic_field_attributes and
  # returns an array of errors added during the creation attempt.  If there aren't any errors and
  # the create operation was successful, an empty array is returned.
  def create_and_collect_errors(enabled_dynamic_field_attributes)
    new_edf = EnabledDynamicField.create(enabled_dynamic_field_attributes)
    collect_errors(new_edf.errors, new_edf.dynamic_field.path.split('/'))
  end

  # Attempts to update the given enabled_dynamic_field with the given new_attributes and returns
  # an array of errors added during the update attempt.  If there aren't any errors and the update
  # operation was successful, an empty array is returned.
  def update_and_collect_errors(enabled_dynamic_field, new_attributes)
    enabled_dynamic_field.update(new_attributes)
    collect_errors(enabled_dynamic_field.errors, enabled_dynamic_field.dynamic_field.path.split('/'))
  end
end
