FactoryBot.define do
  factory :publish_target do
    string_key { 'great_project_website' }
    display_label { 'Great Project Website' }
    publish_url { 'https://www.example.com/publish' }
    api_key { 'bestapikey' }
    association :project, factory: :project, strategy: :create

    factory :legend_of_lincoln_publish_target do
      project { nil } # project should be passed in when factory build or create or called, otherwise this object won't validate
      string_key { 'legend_of_lincoln_website' }
      display_label { 'Legend of Lincoln Website' }
      publish_url { 'https://www.example.com/publish' }
      api_key { '12345' }
      is_allowed_doi_target { true }
    end
  end
end
