module Hyacinth
  module DigitalObject
    module TypeDef
      class DateTime < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super(::DateTime)
        end

        def attribute_to_digital_object_data(value)
          return nil if value.nil?
          value.iso8601
        end

        def digital_object_data_to_attribute(value)
          return nil if value.nil?
          ::DateTime.parse(value)
        end
      end
    end
  end
end
