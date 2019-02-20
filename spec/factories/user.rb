FactoryBot.define do
  factory :user do
    first_name { 'Jane' }
    last_name  { 'Doe' }
    email { 'jane-doe@example.com' }
    is_active { true }
    password { 'terriblepassword' }
    password_confirmation { 'terriblepassword' }
  end
end
