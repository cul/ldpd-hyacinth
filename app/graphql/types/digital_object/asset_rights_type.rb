# frozen_string_literal: true

module Types
  module DigitalObject
    class AssetRightsType < Types::DigitalObject::BaseRights
      Hyacinth::DigitalObject::RightsFields.asset.each do |dynamic_field_group|
        object_type = define_dynamic_field_group_type(dynamic_field_group)

        field dynamic_field_group[:string_key], [object_type], null: true
      end
    end
  end
end