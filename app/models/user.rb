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

  def is_project_admin_for_at_least_one_project?
    return true if self.is_admin?
    return true if ProjectPermission.where(user: self, is_project_admin: true).count > 0

    return false
  end

  def has_project_permission?(project, permission_type)

    return true if self.is_admin?

    valid_permission_types = [:create, :read, :update, :delete, :admin]
    raise 'Permission type must be a symbol (' + permission_type.to_s + ')' if ! permission_type.is_a?(Symbol)
    raise 'Invalid Permission type: ' + permission_type unless valid_permission_types.include?(permission_type)

    possible_project_permission = ProjectPermission.where(user: self, project: project).first

    unless possible_project_permission.nil?
      if possible_project_permission.is_project_admin
        return true
      else
        if permission_type != :admin
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

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = true OR project_permissions.can_update = true').pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_projects_that_use_specific_controlled_vocabulary = EnabledDynamicField.joins(dynamic_field: [:controlled_vocabulary]).where(project_id: projects_for_which_user_can_create_or_edit, 'dynamic_fields.controlled_vocabulary_id' => controlled_vocabulary.id).where('controlled_vocabularies.only_managed_by_admins = false').pluck(:project_id)
      return true if subset_of_projects_that_use_specific_controlled_vocabulary.present?
    end

    return false
  end

  def can_edit_at_least_one_controlled_vocabulary?
    return true if self.is_admin?

    projects_for_which_user_can_create_or_edit = ProjectPermission.where(user: self).where('project_permissions.can_create = true OR project_permissions.can_update = true').pluck(:project_id)

    if projects_for_which_user_can_create_or_edit.present?
      subset_of_projects_that_use_controlled_vocabularies = EnabledDynamicField.joins(dynamic_field: [:controlled_vocabulary]).where(project_id: projects_for_which_user_can_create_or_edit).where('dynamic_fields.controlled_vocabulary_id IS NOT NULL AND controlled_vocabularies.only_managed_by_admins = false').pluck(:project_id)
      return true if subset_of_projects_that_use_controlled_vocabularies.present?
    end

    return false
  end

end
