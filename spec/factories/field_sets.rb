FactoryBot.define do
  factory :field_set do
    display_label { 'Monographs' }
    association :project, factory: :project, strategy: :create

    trait :with_enabled_dynamic_field do
      after_build do |field_set|
        field_set.enabled_dynamic_fields << FactoryBot.create(:enabled_dynamic_field, project: field_set.project)
      end
    end
  end
end
