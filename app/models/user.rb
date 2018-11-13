class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  def full_name
    first_name + ' ' + (middle_name || '') + ' ' + last_name
  end
end
