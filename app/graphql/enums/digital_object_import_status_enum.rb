# frozen_string_literal: true

class Enums::DigitalObjectImportStatusEnum < Types::BaseEnum
  DigitalObjectImport.statuses.each do |value_string, _value_number|
    value str_to_gql_enum(value_string), "Digital object import status of #{value_string}", value: value_string
  end
end
