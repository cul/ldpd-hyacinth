# frozen_string_literal: true

class Mutations::DeletePublishTarget < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :publish_target, Types::PublishTargetType, null: true

  def resolve(string_key:)
    publish_target = PublishTarget.find_by!(string_key: string_key)
    ability.authorize! :delete, publish_target
    publish_target.destroy!
    { publish_target: publish_target }
  end
end
