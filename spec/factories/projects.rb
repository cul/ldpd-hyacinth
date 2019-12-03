# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    string_key    { 'great_project' }
    display_label { 'Great Project' }
    project_url   { 'https://example.com/great_project' }

    trait :legend_of_lincoln do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
      project_url   { 'https://example.com/legend_of_lincoln' }
      is_primary { true }
    end

    trait :myth_of_minken do
      string_key { 'myth_of_minken' }
      display_label { 'Myth of Minken' }
      project_url   { 'https://example.com/myth_of_minken' }
      is_primary { false }
    end

    trait :with_publish_target do
      after(:build) do |project|
        atts = {
          project: project,
          string_key: project.string_key + "_website",
          display_label: project.display_label + " Website",
          publish_url: project.project_url + "/publish"
        }
        create(:legend_of_lincoln_publish_target, atts)
      end
    end
  end
end
