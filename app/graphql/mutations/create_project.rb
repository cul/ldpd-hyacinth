class Mutations::CreateProject < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :project_url, String, required: false

  field :project, Types::ProjectType, null: true

  def resolve(**attributes)
    ability.authorize! :create, Project

    project = Project.new(**attributes)

    project.save!

    { project: project }
  end
end
