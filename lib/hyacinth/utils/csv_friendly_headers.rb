class Hyacinth::Utils::CsvFriendlyHeaders
  CORE_FIELD_LABEL_MAPPING = {
    '_pid' => 'PID',
    '_digital_object_type.string_key' => 'Digital Object Type > String Key',
    '_digital_object_type.pid' => 'Digital Object Type > PID',
    '_project.string_key' => 'Project > String Key',
    '_project.pid' => 'Project > PID',
    '_asset_data.checksum' => 'Asset Data > Checksum',
    '_asset_data.file_size_in_bytes' => 'Asset Data > File Size In Bytes',
    '_asset_data.filesystem_location' => 'Asset Data > Filesystem Location',
    '_asset_data.original_file_path' => 'Asset Data > Original File Path',
    '_asset_data.original_filename' => 'Asset Data > Original Filename',
    '_import_file.import_path' => 'Import File > Import Path',
    '_import_file.import_type' => 'Import File > Import Type',
    '_import_file.original_file_path' => 'Import File > Import Original File Path'
  }

  TERM_CORE_SUBFIELD_LABEL_MAPPING = {
    'authority' => 'Authority',
    'uri' => 'URI',
    'value' => 'Value'
  }

  # Accepts a list of Hyacinth-formatted CSV headers and returns a corresponding list of friendly labels
  def self.hyacinth_headers_to_friendly_headers(hyacinth_headers, df_and_dfg_string_keys_to_display_labels = nil, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys = nil)
    if df_and_dfg_string_keys_to_display_labels.nil? || controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys.nil?
      dynamic_fields = DynamicField.all
      dynamic_field_groups = DynamicFieldGroup.all
    end

    # Collect all DF and DFG string keys and map them to display labels
    if df_and_dfg_string_keys_to_display_labels.nil?
      df_and_dfg_string_keys_to_display_labels = {}
      (dynamic_fields + dynamic_field_groups).each do |df_or_dfg|
        df_and_dfg_string_keys_to_display_labels[df_or_dfg.string_key] = df_or_dfg.display_label
      end
    end

    # Collect all controlled vocabulary field string keys and map them to associated controlled vocabulary string keys
    if controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys.nil?
      controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys = {}
      dynamic_fields.each do |dynamic_field|
        if dynamic_field.dynamic_field_type == DynamicField::Type::CONTROLLED_TERM
          controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys[dynamic_field.string_key] = dynamic_field.controlled_vocabulary_string_key
        end
      end
    end

    hyacinth_headers.map do |header|
      hyacinth_header_to_friendly_header(header, df_and_dfg_string_keys_to_display_labels, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys)
    end
  end

  def self.hyacinth_header_to_friendly_header(header, df_and_dfg_string_keys_to_display_labels, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys)
    if CORE_FIELD_LABEL_MAPPING.key?(header)
      CORE_FIELD_LABEL_MAPPING[header]
    elsif header.start_with?('_publish_targets-')
      header.gsub('_publish_targets-', 'Publish Target ').gsub('.string_key', ' > String Key').gsub('.pid', ' > PID')
    elsif header.start_with?('_parent_digital_objects-')
      header.gsub('_parent_digital_objects-', 'Parent Digital Object ').gsub('.identifier', ' > Identifier').gsub('.pid', ' > PID')
    elsif header.start_with?('_identifiers-')
      header.gsub('_identifiers-', 'Identifier ')
    elsif header.start_with?('_')
      # We're not currently handling unexpected headers that start with an underscore, so we'll just return the original header if it isn't being handled by anything else
      header
    else
      dynamic_field_header_to_friendly_header(header, df_and_dfg_string_keys_to_display_labels, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys)
    end
  end

  def self.dynamic_field_header_to_friendly_header(header, df_and_dfg_string_keys_to_display_labels, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys)
    # Break header up into pieces and replace pieces with correct display labels when applicable
    builder_path = Hyacinth::Csv::Fields::Dynamic.new(header).builder_path

    transformed_builder_path = []
    builder_path.each_with_index do |element, index|
      if element.is_a?(Fixnum)
        # Add one to the number because builder paths are zero-indexed and headers are one-indexed
        transformed_builder_path << element + 1
      elsif index == builder_path.length - 1 && !builder_path[index - 1].is_a?(Fixnum)
        # This is a URI field property, so we need to know which uri field we're working with so that we can get the correct controlled_vocabulary_string_key
        uri_field_name = builder_path[index - 1]
        controlled_vocabulary_string_key = controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys[uri_field_name]
        transformed_builder_path << term_subfield_to_display_label(element, controlled_vocabulary_string_key)
      else
        transformed_builder_path << df_or_dfg_string_key_to_display_label(element, df_and_dfg_string_keys_to_display_labels)
      end
    end
    transformed_builder_path.join('---').gsub(/---(\d)/, ' \1').gsub('---', ' > ')
  end

  def self.term_subfield_to_display_label(term_subfield, controlled_vocabulary_string_key)
    if TERM_CORE_SUBFIELD_LABEL_MAPPING.key?(term_subfield)
      TERM_CORE_SUBFIELD_LABEL_MAPPING[term_subfield]
    elsif controlled_vocabulary_string_key.present? && TERM_ADDITIONAL_FIELDS[controlled_vocabulary_string_key].present? && TERM_ADDITIONAL_FIELDS[controlled_vocabulary_string_key][term_subfield].present? && TERM_ADDITIONAL_FIELDS[controlled_vocabulary_string_key][term_subfield]['display_label']
      TERM_ADDITIONAL_FIELDS[controlled_vocabulary_string_key][term_subfield]['display_label']
    else
      term_subfield
    end
  end

  def self.df_or_dfg_string_key_to_display_label(string_key, df_and_dfg_string_keys_to_display_labels)
    # This is a dynamic field or dynamic field group
    if df_and_dfg_string_keys_to_display_labels.key?(string_key)
      df_and_dfg_string_keys_to_display_labels[string_key]
    else
      string_key
    end
  end
end
