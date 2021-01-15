# frozen_string_literal: true

class Enums::TermTypeEnum < Types::BaseEnum
  {
    'external' => 'term from an external vocabulary',
    'temporary' => 'term with a temporary uri',
    'local' => 'term local to our instance',
  }.each do |val, description|
    value val.upcase.tr(' ', '_'), description, value: val
  end
end
