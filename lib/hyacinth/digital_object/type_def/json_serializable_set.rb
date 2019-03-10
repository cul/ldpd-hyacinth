# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableSet < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def from_serialized_form(value)
          Set.new(value) # parsed JSON value will come in as an Array, so we need to convert to a Set
        end
      end
    end
  end
end
