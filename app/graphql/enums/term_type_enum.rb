# frozen_string_literal: true

class Enums::TermTypeEnum < Types::BaseEnum
  {
    'external' => 'term from an external vocabulary',
    'temporary' => 'term with a temporary uri',
    'local' => 'term local to our instance'
  }.each do |val, description|
    value str_to_gql_enum(val), description, value: val
  end
end
