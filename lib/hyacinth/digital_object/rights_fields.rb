# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength, Metrics/MethodLength
module Hyacinth
  module DigitalObject
    module RightsFields
      # Returns list of mock dynamic field group definitions for the rights item form.
      #
      # This is temporary solution to help generate the GraphQL types for item rights. Eventually, we will want to move
      # towards creating dynamic field group and dynamic field definitions for these fields. This will help us expose
      # field configuration to the UI, so that the item rights form can generate fields based on their configuration.
      def self.item
        [
          {
            type: "DynamicFieldGroup",
            string_key: "descriptive_metadata",
            children: [
              { string_key: "type_of_content", field_type: "select", select_options: "{}", type: "DynamicField" },
              { string_key: "country_of_origin", field_type: "controlled_term", controlled_vocabulary: "geonames", type: "DynamicField" },
              { string_key: "film_distributed_to_public", field_type: "boolean", type: "DynamicField" },
              { string_key: "film_distributed_commercially", field_type: "boolean", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "copyright_status",
            is_repeatable: false,
            children: [
              { string_key: "copyright_statement", field_type: "controlled_term", controlled_vocabulary: "rights_statement", type: "DynamicField" },
              { string_key: "copyright_notes", field_type: "textarea", type: "DynamicField" },
              { string_key: "copyright_registered", field_type: "boolean", type: "DynamicField" },
              { string_key: "copyright_renewed", field_type: "boolean", type: "DynamicField" },
              { string_key: "copyright_date_of_renewal", field_type: "date", type: "DynamicField" },
              { string_key: "copyright_expiration_date", field_type: "date", type: "DynamicField" },
              { string_key: "cul_copyright_assessment_date", field_type: "date", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "copyright_ownership",
            is_repeatable: true,
            children: [
              { string_key: "name", field_type: "controlled_term", controlled_vocabulary: "name", type: "DynamicField" },
              { string_key: "heirs", field_type: "string", type: "DynamicField" },
              { string_key: "contact_information", field_type: "textarea", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "columbia_university_is_copyright_holder",
            is_repeatable: false,
            children: [
              { string_key: "date_of_transfer", field_type: "date", type: "DynamicField" },
              { string_key: "date_of_expiration", field_type: "date", type: "DynamicField" },
              { string_key: "transfer_documentation", field_type: "string", type: "DynamicField" },
              { string_key: "other_transfer_evidence", field_type: "string", type: "DynamicField" },
              { string_key: "transfer_documentation_note", field_type: "string", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "licensed_to_columbia_university",
            is_repeatable: false,
            children: [
              { string_key: "date_of_license", field_type: "date", type: "DynamicField" },
              { string_key: "termination_date_of_license", field_type: "date", type: "DynamicField" },
              { string_key: "credits", field_type: "string", type: "DynamicField" },
              { string_key: "acknowledgements", field_type: "string", type: "DynamicField" },
              { string_key: "license_documentation_location", field_type: "string", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "rights_for_works_of_art_sculpture_and_photographs",
            is_repeatable: false,
            children: [
              { string_key: "publicity_rights_present", field_type: "string", type: "DynamicField" },
              { string_key: "trademarks_prominently_visible", field_type: "boolean", type: "DynamicField" },
              { string_key: "sensitive_in_nature", field_type: "boolean", type: "DynamicField" },
              { string_key: "privacy_concerns", field_type: "boolean", type: "DynamicField" },
              { string_key: "children_materially_identifiable_in_work", field_type: "boolean", type: "DynamicField" },
              { string_key: "vara_rights_concerns", field_type: "boolean", type: "DynamicField" },
              { string_key: "note", field_type: "string", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "contractual_limitations_restrictions_and_permissions",
            children: [
              { string_key: "option_a", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_b", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_c", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_d", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_e", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_a", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_b", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_c", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_d", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_e", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_f", field_type: "boolean", type: "DynamicField" },
              { string_key: "option_av_g", field_type: "boolean", type: "DynamicField" },
              { string_key: "reproduction_and_distribution_prohibited_until", field_type: "date", type: "DynamicField" },
              { string_key: "photographic_or_film_credit", field_type: "string", type: "DynamicField" },
              { string_key: "excerpt_limited_to", field_type: "string", type: "DynamicField" },
              { string_key: "other", field_type: "string", type: "DynamicField" },
              {
                type: "DynamicFieldGroup",
                string_key: "permissions_granted_as_part_of_the_use_license",
                field_type: "select",
                children: [
                  { string_key: "value", field_type: "select", type: "DynamicField" } # MultiSelect
                ]
              }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "underlying_rights",
            children: [
              { string_key: "note", field_type: "string", type: "DynamicField" },
              { string_key: "talent_rights", field_type: "select", type: "DynamicField" },
              { string_key: "columbia_music_license", field_type: "select", type: "DynamicField" },
              { string_key: "composition", field_type: "string", type: "DynamicField" },
              { string_key: "recording", field_type: "string", type: "DynamicField" },
              {
                type: "DynamicFieldGroup",
                string_key: "other_underlying_rights",
                is_repeatable: true,
                children: [
                  { string_key: "value", field_type: "select", type: "DynamicField" } # MultiSelect
                ]
              },
              { string_key: "other", field_type: "string", type: "DynamicField" }
            ]
          }
        ]
      end

      def self.asset
        [
          {
            type: "DynamicFieldGroup",
            string_key: "restriction_on_access",
            is_repeatable: true,
            children: [
              { string_key: "value", field_type: "select", type: "DynamicField" },
              { string_key: "embargo_release", field_type: "date", type: "DynamicField" },
              {
                type: "DynamicFieldGroup",
                string_key: "location",
                is_repeatable: true,
                children: [
                  { string_key: "term", field_type: "controlled_term", controlled_vocabulary: "location", type: "DynamicField" }
                ]
              },
              {
                type: "DynamicFieldGroup",
                string_key: "affiliation",
                is_repeatable: true,
                children: [
                  { string_key: "value", field_type: "string", type: "DynamicField" }
                ]
              },
              { string_key: "note", field_type: "string", type: "DynamicField" }
            ]
          },
          {
            type: "DynamicFieldGroup",
            string_key: "copyright_status_override",
            is_repeatable: false,
            children: [
              { string_key: "copyright_statement", field_type: "controlled_term", controlled_vocabulary: "rights_statement", type: "DynamicField" },
              { string_key: "copyright_notes", field_type: "textarea", type: "DynamicField" },
              { string_key: "copyright_registered", field_type: "boolean", type: "DynamicField" },
              { string_key: "copyright_renewed", field_type: "boolean", type: "DynamicField" },
              { string_key: "copyright_date_of_renewal", field_type: "date", type: "DynamicField" },
              { string_key: "copyright_expiration_date", field_type: "date", type: "DynamicField" },
              { string_key: "cul_copyright_assessment_date", field_type: "date", type: "DynamicField" }
            ]
          }
        ]
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength, Metrics/MethodLength
