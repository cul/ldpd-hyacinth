# frozen_string_literal: true

class Mutations::DeleteProject < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :project, Types::ProjectType, null: true

  def resolve(string_key:)
    project = Project.find_by!(string_key: string_key)

    ability.authorize! :delete, project

    project.destroy!

    { project: project }
  end
end
