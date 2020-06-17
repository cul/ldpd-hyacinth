# frozen_string_literal: true

module Mutations
  module FieldExportProfile
    class CreateFieldExportProfile < Mutations::BaseMutation
      argument :name, String, required: true
      argument :translation_logic, GraphQL::Types::JSON, required: true

      field :field_export_profile, Types::FieldExportProfileType, null: false

      def resolve(**attributes)
        ability.authorize! :create, ::FieldExportProfile

        field_export_profile = ::FieldExportProfile.create(**attributes)

        field_export_profile.save!

        { field_export_profile: field_export_profile }
      end
    end
  end
end
