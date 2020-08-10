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

  def resolve(project:, digital_object_type:, enabled_dynamic_fields:)
    search_params = { digital_object_type: digital_object_type }
    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      project = Project.find_by!(project.to_h)
      # Ensure that the user initiating this update is allowed to do so for the given project
      ability.authorize! :update, project
      search_params[:project_id] = project.id
      EnabledDynamicField.where(search_params).delete_all
      enabled_dynamic_fields.each do |enabled_dynamic_field|
        attributes = search_params.merge(enabled_dynamic_field.to_h)
        attributes[:dynamic_field_id] = attributes.delete(:dynamic_field).fetch(:id)&.to_i
        attributes[:field_sets] = attributes.delete(:field_sets)&.map { |fs| FieldSet.find(fs[:id].to_i) }
        EnabledDynamicField.create(attributes)
      end
    end

    project_enabled_fields_response(EnabledDynamicField.where(search_params))
  end

  def project_enabled_fields_response(enabled_fields)
    {
      project_enabled_fields: enabled_fields
    }
  end
end
