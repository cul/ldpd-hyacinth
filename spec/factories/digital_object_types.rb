# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :digital_object_type do
    string_key "MyString"
    display_label "MyString"
  end
end
