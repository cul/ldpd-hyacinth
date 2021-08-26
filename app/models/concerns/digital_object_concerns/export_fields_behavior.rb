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
        'created_at' => created_at&.iso8601,
        'updated_at' => updated_at&.iso8601,
        'first_published_at' => first_published_at ? first_published_at.iso8601 : '',
        'doi' => doi.present? ? doi.sub(/^doi:/, '') : '',
        'uid' => uid
      }.merge(project_internal_fields).merge(title_internal_fields)
    end

    private

      def project_internal_fields
        {
          'primary_project.string_key' => primary_project.string_key.present? ? primary_project.string_key : '',
          'primary_project.display_label' => primary_project.display_label.present? ? primary_project.display_label : '',
          'primary_project.project_url' => primary_project.project_url.present? ? primary_project.project_url : ''
        }
      end

      def title_internal_fields
        return {} unless title.present?
        result = {
          'title' => generate_label,
          'title.non_sort_portion' => title['non_sort_portion'],
          'title.sort_portion' => title['sort_portion'],
          'title.subtitle' => title['subtitle']
        }
        lang = title['lang'].present? ? Language::Tag.for(title['lang']) : Hyacinth::Config.default_lang_value
        result['title.lang'] = lang.lang.subtag
        result['title.script'] = lang.script&.subtag
        result['title.xml_lang'] = lang.tag
        result
      end
  end
end
