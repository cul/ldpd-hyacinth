FactoryBot.define do
  factory :publish_target do
    factory :legend_of_lincoln_publish_target do
      project { nil } # project should be passed in when factory build or create or called, otherwise this object won't validate
      string_key { 'legend_of_lincoln_website' }
      display_label { 'Legend of Lincoln Website' }
      publish_url { 'https://www.example.com/publish' }
      api_key { '12345' }
    end
  end
end
