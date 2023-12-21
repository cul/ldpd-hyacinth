FactoryBot.define do
  factory :controlled_vocabulary do
    string_key "default_string_key"
    require_controlled_vocabulary_manager_permission false

    trait :prohibit_temp_terms do
      prohibit_temp_terms true
    end
  end
end
