module DigitalObject::DynamicField::ValueResolution
  extend ActiveSupport::Concern

  INTERNAL_FIELD_VALUE_PROCS = {
    '$project.display_label' => proc { |obj| obj.project.display_label },
    '$project.uri' => proc { |obj| obj.project.uri.present? ? obj.project.uri : '' },
    '$created_at' => proc { |obj| obj.created_at },
    '$updated_at' => proc { |obj| obj.updated_at }
  }
  DATA_UNAVAILABLE = proc { |_obj| 'Data unavailable' }

  def resolve_value_hash(value, df_data)
    # Array elements that are strings will be treated like val objects: {'val' => 'some string'}
    return { 'val' => value } if value.is_a? String

    # The output of a ternary evaluation gets placed in a {'val' => 'some value'}, so the normal 'val' evaluation code still runs.
    if value['ternary'].present?
      value['val'] = resolve_ternary(value['ternary'], df_data)
    elsif value['join'].present?
      value['val'] = resolve_join(value['join'], df_data)
    end

    value
  end

  def value_with_substitutions(value, df_data)
    value.gsub(/(\{\{(?:(?!\}\}).)+\}\})/) do |sub|
      # Need to cast to string just in case we're working with a numeric or boolean value
      value_for_field_name(sub[2, sub.length - 4], df_data).to_s
    end
  end

  def value_for_field_name(field_name, df_data)
    # Field names beginning with a '$' are a special substitution that we handle differently.
    # We only allow certain fields
    return INTERNAL_FIELD_VALUE_PROCS.fetch(field_name, DATA_UNAVAILABLE).call(self) if field_name.start_with?('$')
    # This is dot notation for uri-based or indexed terms
    term_part_arr = field_name.split('.').map { |part| part =~ /^\d+/ ? part.to_i : part }
    if df_data.key?(term_part_arr[0])
      return df_data.fetch(term_part_arr[0], '') if term_part_arr[1].nil? && !df_data[term_part_arr[0]].is_a?(Enumerable)

      return df_data[term_part_arr[0]].fetch(term_part_arr[1], '')
    end
    ''
  end

  def resolve_ternary(ternary_arr, df_data)
    # The value of a ternary key is a three-element array.
    # - The first element is a variable to evaluate as true or false.
    # - The second is the value to use if the variable evaluates to true.
    # - The third is the value to use if the variable evaluates to false.
    value_for_field_name(ternary_arr[0], df_data).present? ? ternary_arr[1] : ternary_arr[2]
  end

  # Joins the given strings using the given delimiter, omitting blank values
  def resolve_join(join_data, df_data)
    # join_data is of the format:
    # {
    #   "delimiter" => ",",
    #   "pieces" => ["field_name1", "field_name2.value", "field_name3", ...]
    # }
    # OR
    # {
    #   "delimiter" => ",",
    #   "pieces" => [
    #      {
    #          "ternary": [
    #              "location_shelf_location_box_number",
    #              "Box no. {{location_shelf_location_box_number}}",
    #              ""
    #          ]
    #      },
    #      {
    #          "ternary": [
    #              "location_shelf_location_folder_number",
    #              "Folder no. {{location_shelf_location_folder_number}}",
    #              ""
    #          ]
    #      },
    #      ...
    #      ...
    #   ]
    # }
    delimiter = join_data['delimiter']
    pieces = join_data['pieces'].map do |piece|
      if piece.is_a?(String)
        value_with_substitutions(piece, df_data)
      elsif piece.is_a?(Hash) && piece['ternary'].present?
        value_with_substitutions(render_output_of_ternary(piece['ternary'], df_data), df_data)
      end
    end
    pieces.delete_if(&:blank?) # Remove blank values
    pieces.join(delimiter)
  end
end
