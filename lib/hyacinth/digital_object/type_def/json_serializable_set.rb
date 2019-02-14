# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableSet < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def initialize
          super(::Set)
        end

        def attribute_to_digital_object_data(value)
          value.to_a # need to convert Set to json
        end

        def digital_object_data_to_attribute(value)
          Set.new(value) # value will come from JSON as an Array, so we need to convert to Set
        end
      end
    end
  end
end
