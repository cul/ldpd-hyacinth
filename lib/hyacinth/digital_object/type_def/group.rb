module Hyacinth
  module DigitalObject
    module TypeDef
      class Group < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(group)
          return nil if group.nil?
          {
            'string_key' => group.string_key
          }
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          ::Group.find_by(string_key: json_var['string_key'])
        end
      end
    end
  end
end
