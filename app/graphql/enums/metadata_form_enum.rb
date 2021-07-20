# frozen_string_literal: true

class Enums::MetadataFormEnum < Types::BaseEnum
  DynamicFieldCategory.metadata_forms.each do |value_string, _value_number|
    value str_to_gql_enum(value_string), "Metadata form of #{value_string}", value: value_string
  end
end
