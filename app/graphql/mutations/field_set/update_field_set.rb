class Mutations::FieldSet::UpdateFieldSet < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :id, ID, required: true
  argument :display_label, String, required: false

  field :field_set, Types::FieldSetType, null: true

  def resolve(project_string_key:, id:, **attributes)
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    field_set = project.field_sets.find_by!(id: id)

    ability.authorize! :update, field_set

    field_set.update!(**attributes)

    { field_set: field_set }
  end
end
