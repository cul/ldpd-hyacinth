module DigitalObject::XmlDatastreamRendering
  extend ActiveSupport::Concern

  def render_xml_datastream(xml_datastream)
    base_translation_logic = JSON(xml_datastream.xml_translation)
    dynamic_field_group_map = Hash[DynamicFieldGroup.all.map { |dfg| [dfg.string_key, dfg.xml_translation] }]

    Hyacinth::XmlGenerator
      .new(self.dynamic_field_data, base_translation_logic, dynamic_field_group_map, internal_fields)
      .generate
      .to_xml(indent: 2)
  end

  private

    def internal_fields
      {
        'project.string_key' => self.project.string_key,
        'project.display_label' => self.project.display_label,
        'project.short_label'   => self.project.short_label.present? ? self.project.short_label : self.project.display_label,
        'project.uri'           => self.project.uri.present? ? self.project.uri : '',
        'created_at'            => created_at.iso8601,
        'updated_at'            => updated_at.iso8601,
        'first_published_at'    => first_published_at ? first_published_at.iso8601 : '',
        'doi'                   => doi.present? ? doi.sub(/^doi:/, '') : '',
        'uuid'                  => uuid.present? ? uuid : ''
      }
    end
end
