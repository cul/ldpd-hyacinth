module Hyacinth
  class XMLGenerator::Element
    attr_reader :generator, :parent_element, :xml_translation, :df_data,
                :dynamic_fields_groups_map, :ng_element

    def initialize(generator, parent_element, xml_translation, df_data)
      @generator = generator
      @parent_element = parent_element
      @xml_translation = xml_translation
      @df_data = df_data
      @dynamic_fields_groups_map = generator.dynamic_fields_groups_map
    end

    def generate
      # Return if element shouldn't be rended based on render_if arguments.
      return unless render?(xml_translation.fetch('render_if', nil))

      create_ng_element # Create new element
      add_attributes

      # Add child content
      content = xml_translation['content']

      # Allow for string value as a shortcut for [{'val' => 'some string'}]
      # Allow for array of strings as a shortcut for [{'val' => 'some string'}, {'val' => 'some other string'}]
      content = Array.wrap(content).map { |c| c.is_a?(Hash) ? c : { 'val' => c } }

      if content.present?
        content.each do |value|
          value['val'] = generate_field_val(value)

          if value.has_key?('yield') # Yield to dynamic_field_group renderer logic
            yield_to_template(value['yield'])
          elsif value.has_key?('element') # Create new child element
            self.class.new(generator, ng_element, value, df_data).generate
          elsif value.has_key?('val') # Render string value in next text node, performing DynamicField value substitution for variables
            processed_val = value_with_substitutions(value['val'])
            ng_element.add_child(Nokogiri::XML::Text.new(processed_val, generator.document))
          end
        end
      end

      parent_element.add_child(ng_element)
    end

    def yield_to_template(yield_to_string_key)
      if dynamic_fields_groups_map.has_key?(yield_to_string_key) && df_data[yield_to_string_key].present?
        yield_to_xml_translation = JSON(dynamic_fields_groups_map[yield_to_string_key])

        df_data[yield_to_string_key].each_with_index do |single_dynamic_field_group_data_value_for_string_key, ix|
          old_index = generator.internal_fields['value_index']
          generator.internal_fields['value_index'] = (ix + 1).to_s
          Array.wrap(yield_to_xml_translation).each do |xml_translation_logic_rule|
            self.class.new(generator, ng_element, xml_translation_logic_rule, single_dynamic_field_group_data_value_for_string_key).generate
          end
          generator.internal_fields['value_index'] = old_index
        end
      end
    end

    # Creates Nokogiri element object
    def create_ng_element
      element_name = xml_translation.fetch('element', nil)
      raise ArgumentError, "element key cannot be blank" if element_name.blank?
      @ng_element = generator.document.create_element(element_name)
    end

    # Add attributes (including namespace definitions) to this element
    def add_attributes
      attrs = xml_translation.fetch('attrs', nil)
      return if attrs.blank?

      attrs.each do |attr_key, attr_val|
        next if attr_val.is_a?(Hash) && !render?(attr_val.fetch('render_if', nil))

        val = generate_field_val(attr_val)
        val.strip! if val.respond_to?(:strip!)

        next if val.blank?

        if attr_key.start_with?('xmlns')
          # Do not treat xmlns attribute additions like other attribute additions.  Add namespace definition instead.
          ng_element.add_namespace_definition(attr_key.gsub(/^xmlns:/, ''), val)
        else
          processed_val = value_with_substitutions(val)
          ng_element.set_attribute(attr_key, processed_val) unless processed_val.blank?
        end
      end
    end

    def generate_field_val(value)
      # Array elements that are strings will be treated like val objects: {'val' => 'some string'}
      return value if value.is_a?(String)

      # The output of a ternary evaluation gets placed in a {'val' => 'some value'}, so the normal 'val' evaluation code still runs.
      if value['ternary'].present?
        render_output_of_ternary(value['ternary'])
      elsif value['join'].present?
        render_output_of_join(value['join'])
      elsif value['val'].present?
        value['val']
      end
    end

    def render?(render_if)
      return true if render_if.nil?

      # Check for DynamicFieldGroup existence and DynamicField non-blank value
      if render_if['present'].present?
        render_if['present'].each do |field_or_field_group|
          return false if !df_data[field_or_field_group].is_a?(Array) && value_for_field_name(field_or_field_group).blank?
        end
      end

      # Check for DynamicFieldGroup existence and DynamicField blank value
      if render_if['absent'].present?
        render_if['absent'].each do |field_or_field_group|
          return false if df_data[field_or_field_group].present? || value_for_field_name(field_or_field_group).present?
        end
      end

      # Comparison value given in xml_translation cannot be blank when using
      # equals/not_equals/equals_any_of/equals_none_of conditionals. Instead
      # absent/present conditionals should be used. Additionally, blank field
      # values are never stored.

      if render_if['equal'].present?
        render_if['equal'].each do |field_string_key, value_to_compare_to|
          raise ArgumentError, 'comparison value cannot be blank' if value_to_compare_to.blank?
          value = value_for_field_name(field_string_key)
          return false if value.blank?
          return value == value_to_compare_to
        end
      end

      if render_if['not_equal'].present?
        render_if['not_equal'].each do |field_string_key, value_to_compare_to|
          raise ArgumentError, 'comparison value cannot be blank' if value_to_compare_to.blank?
          value = value_for_field_name(field_string_key)
          return value != value_to_compare_to
        end
      end

      if render_if['equals_any_of'].present?
        render_if['equals_any_of'].each do |field_string_key, array_values_to_compare_to|
          if !array_values_to_compare_to.is_a?(Array) || array_values_to_compare_to.blank?
            raise ArgumentError, 'comparison value must be a non-empty array'
          end
          value = value_for_field_name(field_string_key)
          return false if value.blank?
          return array_values_to_compare_to.include?(value)
        end
      end

      if render_if['equals_none_of'].present?
        render_if['equals_none_of'].each do |field_string_key, array_values_to_compare_to|
          if !array_values_to_compare_to.is_a?(Array) || array_values_to_compare_to.blank?
            raise ArgumentError, 'comparison value must be a non-empty array'
          end
          value = value_for_field_name(field_string_key)
          return !array_values_to_compare_to.include?(value)
        end
      end

      true
    end

    # Captures everything between the {{}} and replaces it with the value provided in the df_data map.
    # Converts value found to string, incase we're working with a numeric or boolean value.
    # Example: "My favorite food is {{food}}!"
    def value_with_substitutions(value)
      value.gsub(/(\{\{(?:(?!\}\}).)+\}\})/) do |sub|
        value_for_field_name(sub[2, sub.length - 4]).to_s
      end
    end

    def value_for_field_name(field_name)
      if field_name.start_with?('$')
        if value = generator.internal_fields.fetch(field_name[1..-1], nil)
          value
        else
          'Data unavailable'
        end
      elsif df_data.has_key?(field_name) && !df_data[field_name].is_a?(Array)
        df_data[field_name]
      elsif field_name.index('.') # This is dot notation for uri-based terms
        term_part_arr = field_name.split('.')
        if df_data[term_part_arr[0]].is_a?(Hash) && df_data[term_part_arr[0]][term_part_arr[1]].present?
          df_data[term_part_arr[0]][term_part_arr[1]]
        else
          ''
        end
      else
        ''
      end
    end


    # This method mimics a ternary operation, but using a three-element array. The
    # array is evaluated as follows:
    # - The first element is a variable to evaluate as true or false.
    # - The second is the value to use if the variable evaluates to true.
    # - The third is the value to use if the variable evaluates to false.
    def render_output_of_ternary(ternary_arr)
      value_for_field_name(ternary_arr[0]).present? ? ternary_arr[1] : ternary_arr[2]
    end

    # Joins the given strings using the given delimiter, omitting blank values
    def render_output_of_join(join_data)
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
      delimiter = join_data['delimiter']
      pieces = join_data['pieces'].map do |piece|
        if piece.is_a?(String)
          value_with_substitutions(piece)
        elsif piece.is_a?(Hash) && piece['ternary'].present?
          value_with_substitutions(render_output_of_ternary(piece['ternary']))
        end
      end
      pieces.delete_if(&:blank?).join(delimiter)
    end
  end
end
