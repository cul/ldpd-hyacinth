class Mutations::CreatePublishTarget < Mutations::BaseMutation
  argument :project_string_key, ID, required: true
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :publish_url, String, required: true
  argument :api_key, String, required: true
  argument :doi_priority, Integer, required: false
  argument :is_allowed_doi_target, Boolean, required: false

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(project_string_key:, **attributes)
    # check that we can do something with project
    project = Project.find_by!(string_key: project_string_key)

    ability.authorize! :read, project

    # ability.authorize! :create, PublishTarget # for this project

    publish_target = project.publish_targets.build(**attributes)

    ability.authorize! :create, publish_target

    publish_target.save!

    { publish_target: publish_target }
  end
end
