# frozen_string_literal: true

module Types
  module DigitalObject
    class ItemRightsType < Types::DigitalObject::BaseRights
      Hyacinth::DigitalObject::RightsFields.item.each do |dynamic_field_group|
        object_type = define_dynamic_field_group_type(dynamic_field_group)

        string_key = dynamic_field_group[:string_key]

        field string_key, [object_type], null: false, resolve: ->(o, _, _) { o.fetch(string_key, []) }
      end
    end
  end
end
