# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    string_key    { 'great_project' }
    display_label { 'Great Project' }
    project_url   { 'https://example.com/great_project' }
    is_primary { true }
    has_asset_rights { false }

    trait :legend_of_lincoln do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
      project_url   { 'https://example.com/legend_of_lincoln' }
      is_primary { true }
    end

    trait :history_of_hamilton do
      string_key { 'history_of_hamilton' }
      display_label { 'History of Hamilton' }
      project_url   { 'https://example.com/history_of_hamilton' }
      is_primary { true }
    end

    trait :myth_of_minken do
      string_key { 'myth_of_minken' }
      display_label { 'Myth of Minken' }
      project_url   { 'https://example.com/myth_of_minken' }
      is_primary { false }
    end

    trait :allow_asset_rights do
      has_asset_rights { true }
    end

    trait :with_publish_target do
      after(:build) do |project|
        atts = {
          project: project,
          target_type: PublishTarget::Type::PRODUCTION,
          publish_url: project.project_url + "/publish"
        }
        create(:legend_of_lincoln_publish_target, atts)
      end
    end

    trait :with_enabled_dynamic_field do
      after(:build) do |project|
        create(:enabled_dynamic_field, project: project)
      end
    end
  end
end
