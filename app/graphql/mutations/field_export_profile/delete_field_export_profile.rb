# frozen_string_literal: true

module Mutations
  module FieldExportProfile
    class DeleteFieldExportProfile < Mutations::BaseMutation
      argument :id, ID, required: true

      field :field_export_profile, Types::FieldExportProfileType, null: false

      def resolve(id:)
        field_export_profile = ::FieldExportProfile.find(id)

        ability.authorize! :destroy, field_export_profile

        field_export_profile.destroy!

        { field_export_profile: field_export_profile }
      end
    end
  end
end
