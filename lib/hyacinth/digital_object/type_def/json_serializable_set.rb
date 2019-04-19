# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableSet < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          json_var.to_set # parsed JSON value will come in as an Array, so we need to convert to a Set
        end

        def to_serialized_form_impl(json_var)
          json_var.to_a # need to convert to an Array for serialization
        end
      end
    end
  end
end
