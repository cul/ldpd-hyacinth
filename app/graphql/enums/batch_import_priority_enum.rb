# frozen_string_literal: true

class Enums::BatchImportPriorityEnum < Types::BaseEnum
  BatchImport.priorities.each do |value_string, _value_number|
    value value_string.upcase.tr(' ', '_'), "Batch import priority of #{value_string}", value: value_string
  end
end
