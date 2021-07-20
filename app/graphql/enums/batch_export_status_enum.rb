# frozen_string_literal: true

class Enums::BatchExportStatusEnum < Types::BaseEnum
  BatchExport.statuses.each do |value_string, _value_number|
    value str_to_gql_enum(value_string), "Batch export status of #{value_string}", value: value_string
  end
end
