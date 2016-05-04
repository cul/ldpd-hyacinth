class User < ActiveRecord::Base
  CONTROLLED_VOCABULARIES_JOIN = 'INNER JOIN dynamic_fields ON dynamic_fields.id = enabled_dynamic_fields.dynamic_field_id ' \
    'INNER JOIN controlled_vocabularies ON controlled_vocabularies.string_key = dynamic_fields.controlled_vocabulary_string_key'

  has_many :projects, through: :project_permissions
  has_many :project_permissions, dependent: :destroy
  # has_many :job_managers

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable, :omniauthable
  # :registerable, :recoverable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  def full_name
    first_name + ' ' + last_name
  end

  def admin?
    is_admin
  end

  def can_manage_all_controlled_vocabularies?
    return true if admin?
    can_manage_all_controlled_vocabularies
  end

  def admin_for_at_least_one_project?
    admin? || ProjectPermission.where(user: self, is_project_admin: true).count > 0
  end

  # Returns details about what this user can and cannot do
  def permissions
    project_permissions = []
    ProjectPermission.includes(:project).where(user: self).find_each do |project_permission|
      project_permissions << {
        project_string_key: project_permission.project.string_key,
        project_pid: project_permission.project.pid,
        is_project_admin: project_permission.is_project_admin,
        can_create: project_permission.can_create,
        can_read: project_permission.can_read,
        can_update: project_permission.can_update,
        can_delete: project_permission.can_delete,
        can_publish: project_permission.can_publish
      }
    end

    {
      is_admin: admin?,
      can_manage_all_controlled_vocabularies: can_manage_all_controlled_vocabularies?,
      projects: project_permissions
    }
  end

  def permitted_in_project?(project, permission_type)
    return true if admin?

    valid_permission_types = [:create, :read, :update, :delete, :publish, :project_admin]
    raise 'Permission type must be a symbol (' + permission_type.to_s + ')' unless permission_type.is_a?(Symbol)
    raise 'Invalid Permission type: ' + permission_type unless valid_permission_types.include?(permission_type)

    possible_project_permission = ProjectPermission.find_by(user: self, project: project)

    return false if possible_project_permission.nil?

    if permission_type != :project_admin
      return possible_project_permission.send(('can_' + permission_type.to_s).to_sym)
    else
      return possible_project_permission.is_project_admin
    end
  end

  # A user can manage a given controlled vocabulary's terms if that user is an admin,
  # or if that user has create or edit permissions in a project that makes
  # use of that controlled vocabulary.
  def can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
    return true if admin?
    return true if can_manage_all_controlled_vocabularies?

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = ? OR project_permissions.can_update = ?', true, true).pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_projects_that_use_specific_controlled_vocabulary =
        EnabledDynamicField.joins(CONTROLLED_VOCABULARIES_JOIN)
        .where(project_id: projects_for_which_user_can_create_or_edit, 'dynamic_fields.controlled_vocabulary_string_key' => controlled_vocabulary.string_key)
        .where('controlled_vocabularies.require_controlled_vocabulary_manager_permission = false')
        .pluck(:project_id)
      return true if subset_of_projects_that_use_specific_controlled_vocabulary.present?
    end

    false
  end

  def can_edit_at_least_one_controlled_vocabulary?
    return true if admin?
    return true if can_manage_all_controlled_vocabularies?

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = ? OR project_permissions.can_update = ?', true, true).pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_user_editable_projects_that_use_controlled_vocabularies =
        EnabledDynamicField.joins(CONTROLLED_VOCABULARIES_JOIN)
        .where(project_id: projects_for_which_user_can_create_or_edit)
        .where('dynamic_fields.controlled_vocabulary_string_key IS NOT NULL AND controlled_vocabularies.require_controlled_vocabulary_manager_permission = false')
        .pluck(:project_id)
      return true if subset_of_user_editable_projects_that_use_controlled_vocabularies.present?
    end

    false
  end

  def as_json(_options = {})
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      is_admin: is_admin,
      permissions: permissions
    }
  end
end
