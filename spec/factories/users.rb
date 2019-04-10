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
      after(:create) do |user|
        create(:group, :administrators, users: [user])
      end
    end

    trait :user_manager do
      after(:create) do |user|
        create(:group, :user_managers, users: [user])
      end
    end

    trait :group_manager do
      after(:create) do |user|
        create(:group, :group_managers, users: [user])
      end
    end

    trait :vocabulary_manager do
      after(:create) do |user|
        create(:group, :vocabulary_managers, users: [user])
      end
    end

    trait :read_all do
      after(:create) do |user|
        create(:group, :read_all, users: [user])
      end
    end
  end
end
