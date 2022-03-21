# frozen_string_literal: true

class Mutations::UpdateProjectPublishTargets < Mutations::BaseMutation
  argument :project, Inputs::StringKey, "String key for project", required: true
  argument(
    :publish_targets,
    [Inputs::StringKey],
    "An array representing the new set of enabled publish targets for the given project, "\
    "or an empty array to remove all project enabled publish targets.",
    required: true
  )

  field :enabled_publish_targets, [Types::PublishTargetType], null: false

  def resolve(project:, publish_targets:)
    project = Project.find_by!(project.to_h)
    # Ensure that the user initiating this update is allowed to do so for the given project
    ability.authorize! :update, project
    publish_targets = PublishTarget.where(string_key: publish_targets.map(&:string_key))
    # This should be an all or nothing update
    ActiveRecord::Base.transaction do
      project.publish_targets = publish_targets.to_a
      project.save!
    end

    enabled_publish_targets_response(project.publish_targets)
  end

  def enabled_publish_targets_response(publish_targets)
    {
      enabled_publish_targets: publish_targets.map { |pt| { 'string_key' => pt.string_key } }
    }
  end
end
