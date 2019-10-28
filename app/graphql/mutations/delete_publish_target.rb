class Mutations::DeletePublishTarget < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :string_key, ID, required: true

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(project_string_key:, string_key:)
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    publish_target = PublishTarget.find_by!(project: project, string_key: string_key)

    ability.authorize! :delete, publish_target

    publish_target.destroy!

    { publish_target: publish_target }
  end
end
