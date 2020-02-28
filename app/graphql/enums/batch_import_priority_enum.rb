# frozen_string_literal: true

class Enums::BatchImportPriorityEnum < Types::BaseEnum
  BatchImport.priorities.each do |value_string, _value_number|
    value value_string, value_string
  end
end
