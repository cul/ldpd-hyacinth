# frozen_string_literal: true

class Enums::DigitalObjectTypeEnum < Types::BaseEnum
  ::Hyacinth::Config.digital_object_types.keys.each do |type|
    value str_to_gql_enum(type), "Digital object type of #{type}", value: type
  end
end
