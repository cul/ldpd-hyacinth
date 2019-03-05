FactoryBot.define do
  factory :group do
    string_key { 'developers' }

    trait :administrators do
      string_key { 'administrators' }
      is_admin { true }
    end

    trait :user_managers do
      string_key { 'user_managers' }

      after(:create) do |group|
        create(:permission, action: Permission::MANAGE_USERS, group: group)
      end
    end

    trait :group_managers do
      string_key { 'group_managers' }

      after(:create) do |group|
        create(:permission, action: Permission::MANAGE_GROUPS, group: group)
      end
    end
  end
end
