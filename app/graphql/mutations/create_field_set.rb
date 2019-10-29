class Mutations::CreateFieldSet < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :display_label, String, required: true

  field :field_set, Types::FieldSetType, null: true

  def resolve(project_string_key:, **attributes)
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    field_set = project.field_sets.build(**attributes)

    ability.authorize! :create, field_set

    field_set.save!

    { field_set: field_set }
  end
end
