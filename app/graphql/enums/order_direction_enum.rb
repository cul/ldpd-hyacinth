# frozen_string_literal: true

class Enums::OrderDirectionEnum < Types::BaseEnum
  {
    'asc' => 'ascending',
    'desc' => 'descending'
  }.each do |val, description|
    value str_to_gql_enum(val), description, value: val
  end
end
