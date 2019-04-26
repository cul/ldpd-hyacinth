FactoryBot.define do
  factory :user do
    uid { nil }
    first_name { 'Jane' }
    last_name  { 'Doe' }
    email { 'jane-doe@example.com' }
    is_active { true }
    password { 'terriblepassword' }
    password_confirmation { 'terriblepassword' }

    trait :basic do
      email { 'basic@example.com' }
      first_name { 'Basic' }
      last_name { 'User' }
    end

    trait :administrator do
      email { 'admin-user@example.com' }
      first_name { 'Admin' }
      last_name { 'User' }
      is_admin { true }
    end

    trait :user_manager do
      after(:create) do |user|
        create(:permission, action: Permission::MANAGE_USERS, user: user)
      end
    end

    trait :vocabulary_manager do
      after(:create) do |user|
        create(:permission, action: Permission::MANAGE_VOCABULARIES, user: user)
      end
    end

    trait :read_all do
      after(:create) do |user|
        create(:permission, action: Permission::READ_ALL_DIGITAL_OBJECTS, user: user)
      end
    end
  end
end
