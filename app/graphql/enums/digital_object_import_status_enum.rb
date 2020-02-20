# frozen_string_literal: true

class Enums::DigitalObjectImportStatusEnum < Types::BaseEnum
  DigitalObjectImport.statuses.each do |value_string, _value_number|
    value value_string, value_string
  end
end
