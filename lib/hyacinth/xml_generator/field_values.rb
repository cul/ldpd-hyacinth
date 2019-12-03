# frozen_string_literal: true

module Hyacinth
  class XMLGenerator::FieldValues
    attr_reader :generator

    def initialize(generator)
      @generator = generator
    end

    def validate_present(value, label)
      raise ArgumentError, "#{label} cannot be blank" if value.blank?
    end

    def generate_field_val(value, df_data)
      # Array elements that are strings will be treated like val objects: {'val' => 'some string'}
      return value if value.is_a?(String)

      # The output of a ternary evaluation gets placed in a {'val' => 'some value'}, so the normal 'val' evaluation code still runs.
      if value['ternary'].present?
        render_output_of_ternary(value['ternary'], df_data)
      elsif value['join'].present?
        render_output_of_join(value['join'], df_data)
      elsif value['val'].present?
        value['val']
      end
    end

    # Captures everything between the {{}} and replaces it with the value provided in the df_data map.
    # Converts value found to string, incase we're working with a numeric or boolean value.
    # Example: "My favorite food is {{food}}!"
    def value_with_substitutions(value, df_data)
      value.gsub(/(\{\{(?:(?!\}\}).)+\}\})/) do |sub|
        value_for_field_name(sub[2, sub.length - 4], df_data).to_s
      end
    end

    def value_for_field_name(field_name, df_data)
      return generator.internal_fields.fetch(field_name[1..-1], 'Data unavailable') if field_name.start_with?('$')

      return df_data[field_name] if df_data.key?(field_name) && !df_data[field_name].is_a?(Array)

      if field_name.index('.') # This is dot notation for uri-based terms
        term_part_arr = field_name.split('.')
        return df_data[term_part_arr[0]][term_part_arr[1]] if df_data[term_part_arr[0]].is_a?(Hash) &&
                                                              df_data[term_part_arr[0]][term_part_arr[1]].present?
      end
      ''
    end

    # This method mimics a ternary operation, but using a three-element array. The
    # array is evaluated as follows:
    # - The first element is a variable to evaluate as true or false.
    # - The second is the value to use if the variable evaluates to true.
    # - The third is the value to use if the variable evaluates to false.
    def render_output_of_ternary(ternary_arr, df_data)
      value_for_field_name(ternary_arr[0], df_data).present? ? ternary_arr[1] : ternary_arr[2]
    end

    # Joins the given strings using the given delimiter, omitting blank values
    def render_output_of_join(join_data, df_data)
      # join_data is of the format:
      # {
      #   "delimiter" => ",",
      #   "pieces" => ["{{field_name1}}", "{{field_name2.value}}", "{{field_name3}}", ...]
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
      #   ]
      # }
      pieces = join_data['pieces'].map do |piece|
        if piece.is_a?(String)
          value_with_substitutions(piece, df_data)
        elsif piece.is_a?(Hash) && piece['ternary'].present?
          value_with_substitutions(render_output_of_ternary(piece['ternary'], df_data), df_data)
        end
      end
      pieces.delete_if(&:blank?).join(join_data['delimiter'])
    end
  end
end
