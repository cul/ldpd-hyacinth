# frozen_string_literal: true

class Mutations::UpdatePublishTarget < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :type, Enums::PublishTargetTypeEnum, required: true, as: :target_type
  argument :publish_url, String, required: false
  argument :api_key, String, required: false
  argument :doi_priority, Integer, required: false
  argument :is_allowed_doi_target, Boolean, required: false

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(project_string_key:, target_type:, **attributes)
    # check that we can do something with project
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    # ability.authorize! :create, PublishTarget # for this project

    publish_target = project.publish_targets.find_by!(target_type: target_type)

    ability.authorize! :update, publish_target

    publish_target.update!(**attributes)

    { publish_target: publish_target }
  end
end
