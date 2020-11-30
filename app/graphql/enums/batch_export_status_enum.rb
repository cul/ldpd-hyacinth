# frozen_string_literal: true

class Enums::BatchExportStatusEnum < Types::BaseEnum
  BatchExport.statuses.each do |value_string, _value_number|
    value value_string.upcase.tr(' ', '_'), value_string, value: value_string
  end
end
