# frozen_string_literal: true

module DigitalObjectConcerns
  module ExportFieldsBehavior
    extend ActiveSupport::Concern

    # Exports descriptive_metadata from the digital_object to string data per
    # the export profile.
    # @param export_profile [FieldExportProfile] The export profile of the serialization rules.
    def render_field_export(export_profile)
      export_rules = export_profile.export_rules.group_by(&:dynamic_field_group)
      dynamic_field_groups_map = export_rules.map do |dfg, rules|
        [dfg.string_key, rules.map(&:translation_logic).map { |src| JSON.parse(src) }]
      end.to_h
      translation_logic = JSON.parse(export_profile.translation_logic)
      generator = Hyacinth::XmlGenerator.new(descriptive_metadata, translation_logic,
                                             dynamic_field_groups_map, internal_fields)
      generator.generate.to_xml
    end

    def internal_fields
      {
        'primary_project.display_label' => primary_project.display_label.present? ? primary_project.display_label : '',
        'primary_project.project_url' => primary_project.project_url.present? ? primary_project.project_url : '',
        'created_at' => created_at.iso8601,
        'updated_at' => updated_at.iso8601,
        'first_published_at' => first_published_at ? first_published_at.iso8601 : '',
        'doi' => doi.present? ? doi.sub(/^doi:/, '') : '',
        'uid' => uid
      }
    end
  end
end
