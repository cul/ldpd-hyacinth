# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authorized_term do
    pid "MyString"
    value "MyText"
    value_uri "MyText"
    authority "MyText"
    authority_uri "MyText"
    controlled_vocabulary nil
  end
end
