class Permission < ApplicationRecord
  MANAGE_VOCABULARIES = 'manage_vocabularies'
  MANAGE_USERS = 'manage_users'
  MANAGE_GROUPS = 'manage_groups'
  MANAGE_ALL_DIGITAL_OBJECTS = 'manage_all_digital_objects'
  READ_ALL_DIGITAL_OBJECTS = 'read_all_digital_objects'

  SYSTEM_WIDE_PERMISSIONS = [
    MANAGE_VOCABULARIES, MANAGE_USERS, MANAGE_GROUPS,
    MANAGE_ALL_DIGITAL_OBJECTS, READ_ALL_DIGITAL_OBJECTS
  ]

  PROJECT_ACTIONS = [
    :read_objects, :create_objects, :update_objects, :delete_objects,
    :publish_objects, :manage
  ]

  belongs_to :group
end
