# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :controlled_vocabulary do
    pid "MyString"
    string_key "MyString"
    display_label "MyString"
    pid_generator nil
  end
end
