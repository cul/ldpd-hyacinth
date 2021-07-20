# frozen_string_literal: true

class Enums::BatchImportPriorityEnum < Types::BaseEnum
  BatchImport.priorities.each do |value_string, _value_number|
    value str_to_gql_enum(value_string), "Batch import priority of #{value_string}", value: value_string
  end
end
