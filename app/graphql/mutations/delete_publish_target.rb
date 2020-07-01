# frozen_string_literal: true

class Mutations::DeletePublishTarget < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :type, Enums::PublishTargetTypeEnum, required: true, as: :target_type

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(project_string_key:, target_type:)
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    publish_target = PublishTarget.find_by!(project: project, target_type: target_type)

    ability.authorize! :delete, publish_target

    publish_target.destroy!

    { publish_target: publish_target }
  end
end
