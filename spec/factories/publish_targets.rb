# frozen_string_literal: true

FactoryBot.define do
  factory :publish_target do
    target_type { PublishTarget::Type::PRODUCTION }
    publish_url { 'https://www.example.com/publish' }
    api_key { 'bestapikey' }
    association :project, factory: :project, strategy: :create

    factory :legend_of_lincoln_publish_target do
      project { nil } # project should be passed in when factory build or create or called, otherwise this object won't validate

      publish_url { 'https://www.example.com/publish' }
      api_key { '12345' }
      is_allowed_doi_target { true }
    end
  end
end
