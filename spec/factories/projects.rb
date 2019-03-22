FactoryBot.define do
  factory :project do
    string_key    { 'great_project' }
    display_label { 'Great Project' }
    project_url   { 'https://example.com/great_project' }

    trait :legend_of_lincoln do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
      project_url   { 'https://example.com/legend_of_lincoln' }
    end
  end
end
