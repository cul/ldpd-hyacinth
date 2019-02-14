# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableBase < Hyacinth::DigitalObject::TypeDef::Base
        # Private constructor for this class because it should not be instantiated.
        private_class_method :new
        # Public constructor for subclasses because they can be instantiated.
        def self.inherited(other); public_class_method :new; end

        def initialize(allowed_class_types)
          super(allowed_class_types)
        end

        def validate(value)
          errors = super(value)

          # We only allow nested objects that can be translated perfectly to json
          # and back (hashes, arrays, strings, integers, floats, and booleans)
          value_as_json = JSON.generate(self.attribute_to_digital_object_data(value))
          if value != self.digital_object_data_to_attribute(JSON.parse(value_as_json))
            errors << "Invalid nested value. #{self.class.name} attribute can only contain JSON-serializable values."
          end
          errors
        end

      end
    end
  end
end
