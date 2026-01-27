class Hyacinth::Utils::CsvHeaderTemplate
  # The following array contains the header strings for the internal fields to include in the
  # template. PLEASE NOTE that we do not include all internal fields in the template,
  CSV_HEADER_TEMPLATE_INTERNAL_FIELDS =
    ["_digital_object_type.string_key", "_identifiers-1", "_parent_digital_objects-1.identifier",
     "_project.string_key", "_import_file.main.import_location", "_import_file.main.original_file_path", "_import_file.main.import_type"]

  # generates the CSV header for a DynamicField that IS NOT a
  # Controlled Term (ct)
  def self.df_header_string_non_ct(arg_df, arg_hash_dfg)
    current_df_or_dfg = arg_df
    path_string = current_df_or_dfg.string_key
    while current_df_or_dfg.parent_dynamic_field_group.present?
      current_df_or_dfg = arg_hash_dfg[current_df_or_dfg.parent_dynamic_field_group_id]
      path_string = current_df_or_dfg.string_key + "-1:" + path_string
    end
    path_string
  end

  # generates the CSV header for a DynamicField that IS a
  # Controlled Term (ct)
  def self.df_header_string_ct(arg_df, arg_hash_dfg)
    current_df_or_dfg = arg_df
    path_string = ''
    while current_df_or_dfg.parent_dynamic_field_group_id
      current_df_or_dfg = arg_hash_dfg[current_df_or_dfg.parent_dynamic_field_group_id]
      path_string = current_df_or_dfg.string_key + "-1:" + path_string
    end
    df_controlled_term_headers = [
      path_string + arg_df.string_key + '.uri',
      path_string + arg_df.string_key + '.authority',
      path_string + arg_df.string_key + '.value'
    ]
    if TERM_ADDITIONAL_FIELDS[arg_df.controlled_vocabulary_string_key].present?
      TERM_ADDITIONAL_FIELDS[arg_df.controlled_vocabulary_string_key].each do |custom_field_key, _custom_field_data|
        df_controlled_term_headers << path_string + arg_df.string_key + '.' + custom_field_key.to_s
      end
    end
    df_controlled_term_headers
  end

  def self.array_dynamic_field_headers(arg_project_id)
    # Preload the DynamicFieldGroups so we don't do a database access each time we need the parent DynamicFieldGroup of a DynamicField
    # Since a DynamicFieldGroup itself can have a parent DynamicFieldGroup, include parent_dynamic_field_group
    preload_dynamic_field_groups =
      Hash[DynamicFieldGroup.includes(:parent_dynamic_field_group).all.map { |dfg| [dfg.id, dfg] }]
    array_header_strings = Array.new(CSV_HEADER_TEMPLATE_INTERNAL_FIELDS)

    enabled_dfs = EnabledDynamicField.includes(:dynamic_field).where(project_id: arg_project_id).select(:dynamic_field_id).distinct

    enabled_dfs.each do |enabled_df|
      if enabled_df.dynamic_field.dynamic_field_type == DynamicField::Type::CONTROLLED_TERM
        df_header_string_ct(enabled_df.dynamic_field,
                            preload_dynamic_field_groups).each do |header_string|
          array_header_strings << header_string
        end
      else
        array_header_strings <<
          df_header_string_non_ct(enabled_df.dynamic_field,
                                  preload_dynamic_field_groups)
      end
    end
    array_header_strings.sort(&ExportSearchResultsToCsvJob.method(:sort_pointers))
  end
end
