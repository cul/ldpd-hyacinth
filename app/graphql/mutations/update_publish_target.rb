# frozen_string_literal: true

class Mutations::UpdatePublishTarget < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :publish_url, String, required: false
  argument :api_key, String, required: false
  argument :doi_priority, Integer, required: false
  argument :is_allowed_doi_target, Boolean, required: false

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(string_key:, **attributes)
    publish_target = PublishTarget.find_by!(string_key: string_key)
    ability.authorize! :update, publish_target
    publish_target.update!(**attributes)
    { publish_target: publish_target }
  end
end
