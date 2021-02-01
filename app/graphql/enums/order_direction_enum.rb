# frozen_string_literal: true

class Enums::OrderDirectionEnum < Types::BaseEnum
  {
    'asc' => 'ascending',
    'desc' => 'descending'
  }.each do |val, description|
    value val.upcase.tr(' ', '_'), description, value: val
  end
end
