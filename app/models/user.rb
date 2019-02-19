class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  has_and_belongs_to_many :groups

  def full_name
    first_name + ' ' + (middle_name || '') + ' ' + last_name
  end

    def as_json(_options = {})
    {
      # uid: uid,
      email: email,
      first_name: first_name,
      last_name: last_name,
      is_active: is_active,
    }
  end
end
