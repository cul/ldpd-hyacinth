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

    trait :myth_of_minken do
      string_key { 'myth_of_minken' }
      display_label { 'Myth of Minken' }
      project_url   { 'https://example.com/myth_of_minken' }
    end
  end
end
