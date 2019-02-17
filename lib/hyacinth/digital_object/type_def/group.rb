module Hyacinth
  module DigitalObject
    module TypeDef
      class Group < Hyacinth::DigitalObject::TypeDef::Base
        def to_json_var(value)
          return nil if value.nil?
          raise NotImplementedError # TODO: Implement
        end

        def from_json_var(value)
          return nil if value.nil?
          raise NotImplementedError # TODO: Implement
        end
      end
    end
  end
end
