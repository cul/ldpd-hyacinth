# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    transient do
      sequence :project_string_key, 1 do |n|
        n == 1 ? 'great_project' : "great_project_#{n}"
      end
    end

    string_key { project_string_key }
    display_label { project_string_key.titleize }
    project_url { "https://example.com/#{project_string_key}" }
    has_asset_rights { false }

    trait :legend_of_lincoln do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
      project_url   { 'https://example.com/legend_of_lincoln' }
    end

    trait :history_of_hamilton do
      string_key { 'history_of_hamilton' }
      display_label { 'History of Hamilton' }
      project_url   { 'https://example.com/history_of_hamilton' }
    end

    trait :myth_of_minken do
      string_key { 'myth_of_minken' }
      display_label { 'Myth of Minken' }
      project_url   { 'https://example.com/myth_of_minken' }
    end

    trait :allow_asset_rights do
      has_asset_rights { true }
    end

    trait :with_enabled_dynamic_field do
      after(:build) do |project|
        create(:enabled_dynamic_field, project: project)
      end
    end

    trait :with_publish_target do
      after(:create) do |instance|
        FactoryBot.create_list(:legend_of_lincoln_publish_target, 1, projects: [instance])
      end
    end
  end
end
