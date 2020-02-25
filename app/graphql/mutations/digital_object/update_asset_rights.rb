# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateAssetRights < Mutations::DigitalObject::BaseRightsMutation
      argument :id, ID, required: true

      Hyacinth::DigitalObject::RightsFields.asset.each do |dynamic_field_group|
        child_input_type = define_dynamic_field_group_input(dynamic_field_group)

        argument dynamic_field_group[:string_key], [child_input_type], required: false
      end

      field :asset, Types::DigitalObject::AssetType, null: false

      def resolve(id:, **rights)
        digital_object = ::DigitalObject::Base.find(id)

        raise "Cannot update item rights for #{digital_object.digital_object_type}" unless digital_object.is_a?(::DigitalObject::Asset)

        ability.authorize! :update_rights, digital_object

        digital_object.rights = rights.deep_transform_values(&:to_h).stringify_keys
        digital_object.save!(update_index: true, user: context[:current_user])
        { asset: digital_object }
      end
    end
  end
end
