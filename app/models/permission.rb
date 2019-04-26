class Permission < ApplicationRecord
  MANAGE_VOCABULARIES = 'manage_vocabularies'
  MANAGE_USERS = 'manage_users'
  MANAGE_ALL_DIGITAL_OBJECTS = 'manage_all_digital_objects'
  READ_ALL_DIGITAL_OBJECTS = 'read_all_digital_objects'

  SYSTEM_WIDE_PERMISSIONS = [
    MANAGE_VOCABULARIES, MANAGE_USERS,
    MANAGE_ALL_DIGITAL_OBJECTS, READ_ALL_DIGITAL_OBJECTS
  ]

  PROJECT_ACTIONS = [
    'read_objects', 'create_objects', 'update_objects', 'delete_objects',
    'publish_objects', 'manage'
  ]

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
      elsif !Permission.valid_project_action?(action)
        errors.add(:action, 'is invalid')
      end
    end
end
