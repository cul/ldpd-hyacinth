class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

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
