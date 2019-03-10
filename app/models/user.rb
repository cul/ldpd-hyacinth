class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  before_create do
    self.uid = SecureRandom.uuid
  end

  def full_name
    first_name + ' ' + (middle_name || '') + ' ' + last_name
  end
end
