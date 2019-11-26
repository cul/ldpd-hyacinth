# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    description 'A project'

    field :string_key, ID, null: false
    field :display_label, String, null: false
    field :project_url, String, null: true

    field :publish_targets, [PublishTargetType], null: true
    field :publish_target, PublishTargetType, null: true do
      argument :string_key, ID, required: true
    end

    field :field_sets, [FieldSetType], null: true
    field :field_set, FieldSetType, null: true do
      argument :id, ID, required: true
    end

    def field_set(id:)
      field_set = FieldSet.find_by!(id: id, project: object)
      context[:ability].authorize!(:show, field_set)
      field_set
    end

    # might need this to enforce permissions
    # don't need to enforce permissions because if a user can see the project they can see all the field sets and publish targets
    # def publish_targets
    # end

    def publish_target(string_key:)
      publish_target = PublishTarget.find_by!(string_key: string_key, project: object)
      context[:ability].authorize!(:show, publish_target)
      publish_target
    end
  end
end
