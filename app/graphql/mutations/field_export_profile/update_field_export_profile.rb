# frozen_string_literal: true

module Mutations
  module FieldExportProfile
    class UpdateFieldExportProfile < Mutations::Term::BaseMutation
      argument :id, ID, required: true
      argument :name, String, required: false
      argument :translation_logic, GraphQL::Types::JSON, required: false

      field :field_export_profile, Types::FieldExportProfileType, null: false

      def resolve(id:, **attributes)
        field_export_profile = ::FieldExportProfile.find(id)

        ability.authorize! :update, field_export_profile

        field_export_profile.update!(**attributes)

        { field_export_profile: field_export_profile }
      end
    end
  end
end
