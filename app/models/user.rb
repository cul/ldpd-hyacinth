class User < ActiveRecord::Base

  has_many :projects, :through => :project_permissions
  has_many :project_permissions, :dependent => :destroy
  #has_many :job_managers

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable, :omniauthable
  # :registerable, :recoverable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  def full_name
    return self.first_name + ' ' + self.last_name
  end

  def is_admin?
    return self.is_admin
  end
  
  def can_manage_all_controlled_vocabularies?
    return true if self.is_admin?
    return self.can_manage_all_controlled_vocabularies
  end

  def is_project_admin_for_at_least_one_project?
    return true if self.is_admin?
    return true if ProjectPermission.where(user: self, is_project_admin: true).count > 0

    return false
  end
  
  # Returns details about what this user can and cannot do
  def get_permissions
    
    project_permissions = []
    ProjectPermission.includes(:project).where(user: self).each do |project_permission|
      project_permissions << {
        project_string_key: project_permission.project.string_key,
        project_pid: project_permission.project.pid,
        is_project_admin: project_permission.is_project_admin,
        can_create: project_permission.can_create,
        can_read: project_permission.can_read,
        can_update: project_permission.can_update,
        can_delete: project_permission.can_delete,
        can_publish: project_permission.can_publish,
      }
    end
    
    return {
      is_admin: self.is_admin?,
      projects: project_permissions
    }
  end

  def has_project_permission?(project, permission_type)

    return true if self.is_admin?

    valid_permission_types = [:create, :read, :update, :delete, :publish, :project_admin]
    raise 'Permission type must be a symbol (' + permission_type.to_s + ')' if ! permission_type.is_a?(Symbol)
    raise 'Invalid Permission type: ' + permission_type unless valid_permission_types.include?(permission_type)

    possible_project_permission = ProjectPermission.where(user: self, project: project).first

    unless possible_project_permission.nil?
      if possible_project_permission.is_project_admin
        return true
      else
        if permission_type != :project_admin
          return true if possible_project_permission.send(('can_' + permission_type.to_s).to_sym)
        end
      end
    end

    return false

  end

  # A user can manage a given controlled vocabulary's terms if that user is an admin,
  # or if that user has create or edit permissions in a project that makes
  # use of that controlled vocabulary.
  def can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
    return true if self.is_admin?
    return true if self.can_manage_all_controlled_vocabularies?

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = ? OR project_permissions.can_update = ?', true, true).pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_projects_that_use_specific_controlled_vocabulary = EnabledDynamicField.joins(
        'INNER JOIN dynamic_fields ON dynamic_fields.id = enabled_dynamic_fields.dynamic_field_id ' +
        'INNER JOIN controlled_vocabularies ON controlled_vocabularies.string_key = dynamic_fields.controlled_vocabulary_string_key'
      ).where(project_id: projects_for_which_user_can_create_or_edit, 'dynamic_fields.controlled_vocabulary_string_key' => controlled_vocabulary.string_key).where('controlled_vocabularies.only_managed_by_admins = false').pluck(:project_id)
      return true if subset_of_projects_that_use_specific_controlled_vocabulary.present?
    end

    return false
  end

  def can_edit_at_least_one_controlled_vocabulary?
    return true if self.is_admin?
    return true if self.can_manage_all_controlled_vocabularies?

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = ? OR project_permissions.can_update = ?', true, true).pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_user_editable_projects_that_use_controlled_vocabularies = EnabledDynamicField.joins(
        'INNER JOIN dynamic_fields ON dynamic_fields.id = enabled_dynamic_fields.dynamic_field_id ' +
        'INNER JOIN controlled_vocabularies ON controlled_vocabularies.string_key = dynamic_fields.controlled_vocabulary_string_key'
      ).where(project_id: projects_for_which_user_can_create_or_edit).where('dynamic_fields.controlled_vocabulary_string_key IS NOT NULL AND controlled_vocabularies.only_managed_by_admins = false').pluck(:project_id)
      return true if subset_of_user_editable_projects_that_use_controlled_vocabularies.present?
    end

    return false
  end
  
  def as_json(options={})
    return {
      id: self.id,
      first_name: self.first_name,
      last_name: self.last_name,
      is_admin: self.is_admin,
      permissions: self.get_permissions
    }
  end

end
