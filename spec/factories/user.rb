FactoryBot.define do
  factory :user do
    first_name { 'Jane' }
    last_name  { 'Doe' }
    email { 'jane-doe@example.com' }
    is_active { true }
    password { 'terriblepassword' }
    password_confirmation { 'terriblepassword' }

    trait :administrator do
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
  end
end
