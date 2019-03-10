class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, if: Proc.new { |a| a.password.present? }, on: :update

  has_and_belongs_to_many :groups

  before_validation :set_uid, on: :create
  validate :uid_unchanged

  def full_name
    first_name + ' ' + (middle_name || '') + ' ' + last_name
  end

  def as_json(_options = {})
    {
      uid: uid,
      email: email,
      first_name: first_name,
      last_name: last_name,
      is_active: is_active,
      groups: groups.map(&:string_key)
    }
  end

  def admin?
    groups.any?(&:admin?)
  end

  # Return system wide permissions/roles that a user is assigned
  #
  # @return [Array<String>] system wide roles assigned
  def system_wide_permissions
    Permission
      .where(group_id: group_ids, subject: nil, subject_id: nil)
      .map(&:action)
  end

  # Return project actions allowed for this user for all the projects given.
  #
  # @param Array|String project_id
  def available_project_actions(project_ids)
    project_ids = Array.wrap(project_ids)
    Permission
      .where(group_id: group_ids, subject: Project.to_s, subject_id: project_ids)
      .map(&:action)
  end

  private

    def set_uid
      if new_record?
        self.uid = SecureRandom.uuid
      else
        raise StandardError, 'Cannot set uid if record has already been persisted.'
      end
    end

    # Check that uid was not changed
    def uid_unchanged
      return unless persisted? # skip if object is new or is deleted
      errors.add(:uid, 'Change of uid not allowed!') if uid_changed?
    end
end
