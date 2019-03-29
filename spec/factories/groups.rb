FactoryBot.define do
  factory :group do
    string_key { 'developers' }

    trait :lincoln_historical_society do
      string_key { 'lincoln_historical_society' }
    end

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

    trait :vocabulary_managers do
      string_key { 'vocabulary_managers' }

      after(:create) do |group|
        create(:permission, action: Permission::MANAGE_VOCABULARIES, group: group)
      end
    end
  end
end
