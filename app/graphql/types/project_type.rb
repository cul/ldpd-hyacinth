# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    description 'A project'

    field :string_key, ID, null: false
    field :display_label, String, null: false
    field :project_url, String, null: true
    field :publish_targets, [PublishTargetType], null: true
    field :field_sets, [FieldSetType], null: true
    field :field_set, FieldSetType, null: true do
      argument :id, ID, required: true
    end

    field :project_permissions, [ProjectPermissionsType], null: true

    field :enabled_digital_object_types, [String], null: false

    field :has_asset_rights, Boolean, null: false

    field :available_publish_targets, [Types::Projects::AvailablePublishTargetType], null: false do
      description "List of all publish targets annotated with enabled switch for project in scope"
    end

    def ability
      context[:ability]
    end

    def field_set(id:)
      field_set = FieldSet.find_by!(id: id, project: object)
      ability.authorize!(:read, field_set)
      field_set
    end

    def project_permissions
      Permission.where(subject: 'Project', subject_id: object).group_by(&:user_id).map do |_user_id, grouped_permissions|
        {
          user: grouped_permissions.first.user,
          project: object,
          actions: grouped_permissions.map(&:action)
        }
      end
    end

    def enabled_digital_object_types
      distinct_types = EnabledDynamicField.where(project: object).distinct('digital_object_type').pluck('digital_object_type')
      # Ensure that values are always returned in consistent
      # alphabetical order so they can be used in UI lists
      distinct_types.sort!
    end

    def available_publish_targets
      enabled = object.publish_targets.map(&:string_key)
      all_publish_targets.map do |publish_target|
        publish_target.as_json.merge('enabled' => enabled.include?(publish_target.string_key))
      end
    end

    private

      def all_publish_targets
        ability.authorize!(:read, PublishTarget)
        PublishTarget.accessible_by(ability).order(:string_key)
      end
  end
end
