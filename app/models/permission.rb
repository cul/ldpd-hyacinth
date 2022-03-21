# frozen_string_literal: true

class Permission < ApplicationRecord
  MANAGE_VOCABULARIES = 'manage_vocabularies'
  MANAGE_USERS = 'manage_users'
  MANAGE_ALL_DIGITAL_OBJECTS = 'manage_all_digital_objects'
  READ_ALL_DIGITAL_OBJECTS = 'read_all_digital_objects'
  MANAGE_RESOURCE_REQUESTS = 'manage_resource_requests'

  SYSTEM_WIDE_PERMISSIONS = [
    MANAGE_VOCABULARIES, MANAGE_USERS,
    MANAGE_ALL_DIGITAL_OBJECTS, READ_ALL_DIGITAL_OBJECTS,
    MANAGE_RESOURCE_REQUESTS
  ].freeze

  PROJECT_ACTION_READ_OBJECTS = 'read_objects'
  PROJECT_ACTION_MANAGE = 'manage'
  PROJECT_ACTION_CREATE_OBJECTS = 'create_objects'
  PROJECT_ACTION_DELETE_OBJECTS = 'delete_objects'
  PROJECT_ACTION_UPDATE_OBJECTS = 'update_objects'
  PROJECT_ACTION_ASSESS_RIGHTS = 'assess_rights'
  PROJECT_ACTION_PUBLISH_OBJECTS = 'publish_objects'

  # NOTE: The order of actions in this array determines display order in the UI.
  PROJECT_ACTIONS = [
    PROJECT_ACTION_READ_OBJECTS, PROJECT_ACTION_CREATE_OBJECTS, PROJECT_ACTION_UPDATE_OBJECTS,
    PROJECT_ACTION_DELETE_OBJECTS, PROJECT_ACTION_PUBLISH_OBJECTS, PROJECT_ACTION_ASSESS_RIGHTS,
    PROJECT_ACTION_MANAGE
  ].freeze

  validate :valid_permission_combination

  belongs_to :user

  def self.valid_system_wide_action?(action)
    SYSTEM_WIDE_PERMISSIONS.include?(action)
  end

  def self.valid_project_action?(action)
    PROJECT_ACTIONS.include?(action)
  end

  private

    def valid_permission_combination
      if subject.blank? && subject_id.blank?
        errors.add(:action, 'is invalid') unless Permission.valid_system_wide_action?(action)
      elsif subject == 'Project'
        validate_project_permission
      else
        errors.add(:subject, 'is invalid')
      end
    end

    def validate_project_permission
      if subject_id.blank?
        errors.add(:subject_id, 'cannot be blank if subject is present')
        return
      end

      errors.add(:action, "#{action} is not allowed for a project") unless Permission.valid_project_action?(action)
    end
end
