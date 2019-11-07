class Mutations::FieldSet::DeleteFieldSet < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :id, ID, required: true

  field :field_set, Types::FieldSetType, null: true

  def resolve(project_string_key:, id:)
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    field_set = FieldSet.find_by!(project: project, id: id)

    ability.authorize! :delete, field_set

    field_set.destroy!

    { field_set: field_set }
  end
end
