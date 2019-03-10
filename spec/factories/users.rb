FactoryBot.define do
  factory :admin_user, class: User do
    uid { '1111-1111' }
    email { 'admin-user@example.com' }
    password { 'ihavethepower' }
    first_name { 'Admin' }
    last_name { 'User' }
  end

  factory :non_admin_user, class: User do
    uid { '2222-2222' }
    email { 'non-admin-user@example.com' }
    password { 'ihavelesspower' }
    first_name { 'Non-Admin' }
    last_name { 'User' }

    # TODO: Add this association after Users and Group have a has_and_belongs_to_many relationship
    # after(:create) do |user|
    #   create(:project1_group, user: user)
    # end
  end
end
