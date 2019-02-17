module Hyacinth
  module DigitalObject
    module TypeDef
      class DateTime < Hyacinth::DigitalObject::TypeDef::Base
        def to_json_var(value)
          return nil if value.nil?
          value.iso8601
        end

        def from_json_var(value)
          return nil if value.nil?
          ::DateTime.parse(value)
        end
      end
    end
  end
end
