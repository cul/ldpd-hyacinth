# frozen_string_literal: true

FactoryBot.define do
  factory :publish_target do
    transient do
      sequence :publish_target_string_key, 1 do |n|
        n == 1 ? 'great_publish_target' : "great_publish_target_#{n}"
      end
    end

    string_key { publish_target_string_key }
    publish_url { 'https://www.example.com/publish' }
    api_key { 'bestapikey' }

    factory :legend_of_lincoln_publish_target do
      api_key { '12345' }
      is_allowed_doi_target { true }
    end
  end
end
