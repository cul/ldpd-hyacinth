class Mutations::UpdateProject < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: false
  argument :project_url, String, required: false

  field :project, Types::ProjectType, null: true

  def resolve(string_key:, **attributes)
    project = Project.find_by!(string_key: string_key)

    ability.authorize! :update, project

    project.update!(**attributes)

    { project: project }
  end
end
