# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateProjects < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :primary_project, Inputs::StringKey, required: true
      argument(
        :other_projects,
        [Inputs::StringKey],
        "An array representing the new set of other projects for the given object, "\
        "or an empty array to remove all projects but the primary.",
        required: true
      )

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, primary_project:, other_projects:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        primary_project_change = proposed_primary_project_change(digital_object, primary_project)
        other_project_change = proposed_other_projects_change(digital_object, primary_project, other_projects)
        authorize_change!(digital_object.primary_project, primary_project_change)

        persist_change(digital_object, primary_project_change, other_project_change) if digital_object.errors.blank?
        projects_update_response(digital_object)
      end

      # look up a proposed primary project unless no change is indicated
      # bad string keys will raise to prevent orphaned digital objects
      # @return proposed new primary project or nil if no change
      def proposed_primary_project_change(digital_object, proposed_primary)
        proposed_string_key = proposed_primary['stringKey']
        Project.find_by!(string_key: proposed_string_key) unless digital_object.primary_project.string_key.eql?(proposed_string_key)
      rescue ActiveRecord::RecordNotFound
        digital_object.errors.add(:primary_project, "missing projects for string keys [\"#{proposed_string_key}\"]")
        nil
      end

      def authorize_change!(current_primary, proposed_primary)
        if proposed_primary
          ability.authorize! :delete_objects, current_primary
          ability.authorize! :create_objects, proposed_primary
        end
        ability.authorize! :update_objects, current_primary
      end

      # @return nil if no change, [other_projects, missing_string_keys] if change indicated
      def proposed_other_projects_change(digital_object, primary_project, other_projects)
        other_project_string_keys = other_projects.map { |pt| pt['stringKey'] }
        # regardless of whether the primary has changed, the requested primary should not be in other_projects
        other_project_string_keys = other_project_string_keys.excluding(primary_project['stringKey'])
        return [] if other_project_string_keys.blank? && digital_object.other_projects.present?
        current = digital_object.other_projects&.map(&:string_key) || []
        return nil if current.sort.eql?(other_project_string_keys.sort)
        other_projects_values = Project.where(string_key: other_project_string_keys).to_a
        (other_project_string_keys - other_projects_values.map(&:string_key)).tap do |missing_projects|
          digital_object.errors.add(:other_projects, "missing projects for string keys #{missing_projects.inspect}") if missing_projects.present?
        end
        other_projects_values
      end

      def persist_change(digital_object, primary_project_change, other_project_change)
        ActiveRecord::Base.transaction do
          digital_object.primary_project = primary_project_change unless primary_project_change.nil?
          digital_object.other_projects = Set.new(other_project_change) unless other_project_change.nil?
          digital_object.updated_by = context[:current_user]
          digital_object.save
        end
      end

      def projects_update_response(digital_object)
        if digital_object.errors.present?
          user_errors = digital_object.errors.map { |error| { path: [error.attribute], message: error.message } }
          { digital_object: nil, user_errors: user_errors }
        else
          { digital_object: digital_object, user_errors: [] }
        end
      end
    end
  end
end
