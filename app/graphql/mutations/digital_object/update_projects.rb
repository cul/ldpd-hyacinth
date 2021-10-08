# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateProjects < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :primary_project, Inputs::StringKey, required: false
      argument(
        :other_projects,
        [Inputs::StringKey],
        "An array representing the new set of other projects for the given object, "\
        "or an empty array to remove all projects but the primary.",
        required: false
      )

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, primary_project: nil, other_projects: nil)
        digital_object = ::DigitalObject.find_by_uid!(id)
        primary_project_change = proposed_primary_project_change(digital_object, primary_project) if primary_project
        other_project_change = proposed_other_projects_change(digital_object, other_projects) if other_projects
        authorize_change!(digital_object.primary_project, primary_project_change, other_project_change)

        persist_change(digital_object, primary_project_change, other_project_change)
        projects_update_response(digital_object)
      rescue Hyacinth::Exceptions::NotFound => ex
        # raised when primary project change cannot be dereferenced
        digital_object.errors.add(:primary_project, ex.message)
        projects_update_response(digital_object)
      end

      # look up a proposed primary project unless no change is indicated
      # bad string keys will raise to prevent orphaned digital objects
      # @return proposed new primary project or nil if no change
      def proposed_primary_project_change(digital_object, proposed_primary)
        proposed_string_key = proposed_primary['stringKey']
        digital_object.dereference_project_string_key(proposed_string_key, true) unless proposed_string_key == digital_object.primary_project.string_key
      end

      def authorize_change!(current_primary, proposed_primary, proposed_other)
        if proposed_primary
          ability.authorize! :delete_objects, current_primary
          ability.authorize! :create_objects, proposed_primary
        end
        ability.authorize!(:update_objects, current_primary) if proposed_other
      end

      # @return nil if no change, [other_projects, missing_string_keys] if change indicated
      def proposed_other_projects_change(digital_object, other_projects)
        return nil if other_projects.nil?
        other_projects = other_projects.map(&:to_h).map(&:stringify_keys)
        other_project_string_keys = other_projects.map { |pt| pt['string_key'] }
        current = digital_object.other_projects&.map(&:string_key) || []
        return nil if current.sort.eql?(other_project_string_keys.sort)
        other_projects
      end

      def persist_change(digital_object, primary_project_change, other_project_change)
        projects_change = {
          'primary_project' => primary_project_change,
          'other_projects' => other_project_change
        }.compact
        return if projects_change.blank?
        ActiveRecord::Base.transaction do
          digital_object.assign_attributes(projects_change)
          digital_object.updated_by = context[:current_user]
          digital_object.save!
        end
      rescue Hyacinth::Exceptions::NotFound, ActiveRecord::RecordInvalid => ex
        # raised when other project change cannot be dereferenced, or is invalid
        digital_object.errors.add(:other_projects, ex.message)
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
