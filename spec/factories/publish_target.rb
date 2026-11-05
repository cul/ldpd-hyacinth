FactoryBot.define do
  factory :publish_target do
    string_key { "publish_target_#{SecureRandom.hex(8)}" }
    display_label { 'Test Publish Target' }
    publish_url { 'http://localhost/publish' }
    api_key { 'test_api_key' }
  end
end
