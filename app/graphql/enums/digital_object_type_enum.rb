# frozen_string_literal: true

class Enums::DigitalObjectTypeEnum < Types::BaseEnum
  ::Hyacinth::Config.digital_object_types.keys.each do |type|
    value type, type.camelize
  end
end
