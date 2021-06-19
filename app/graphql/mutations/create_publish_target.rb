# frozen_string_literal: true

class Mutations::CreatePublishTarget < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :publish_url, String, required: true
  argument :api_key, String, required: true
  argument :doi_priority, Integer, required: false
  argument :is_allowed_doi_target, Boolean, required: false

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(**attributes)
    ability.authorize! :create, PublishTarget
    publish_target = PublishTarget.create!(**attributes)
    { publish_target: publish_target }
  end
end
