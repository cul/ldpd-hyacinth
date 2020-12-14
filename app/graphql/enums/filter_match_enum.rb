# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  {
    'contains' => 'contains',
    'does_not_contain' => 'does not contain',
    'does_not_equal' => 'does not equal',
    'does_not_exist' => 'does not exist',
    'does_not_start_with' => 'does not start with',
    'equals' => 'equals',
    'exists' => 'exists',
    'starts_with' => 'starts with'
  }.each do |val, description|
    value val.upcase.tr(' ', '_'), description, value: val
  end
end
