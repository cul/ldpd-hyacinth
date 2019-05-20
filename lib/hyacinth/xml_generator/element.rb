module Hyacinth
  class XMLGenerator::Element
    attr_reader :generator, :field_values
    delegate :generate_field_val, :value_with_substitutions, :value_for_field_name,
             :render_output_of_ternary, :render_output_of_join, to: :field_values
    def initialize(generator)
      @generator = generator
      @field_values = XMLGenerator::FieldValues.new(generator)
    end

    def validate_present(value, label)
      raise ArgumentError, "#{label} cannot be blank" if value.blank?
    end

    def generate(xml_translation, df_data, parent_element)
      # Return if element shouldn't be rended based on render_if arguments.
      return unless render?(xml_translation.fetch('render_if', nil), df_data)

      ng_element = create_ng_element(xml_translation, parent_element.document) # Create new element
      add_attributes(xml_translation, df_data, ng_element)

      # Add child content
      generate_ng_element_content(generator.dynamic_fields_groups_map, df_data, ng_element, xml_translation['content']) if xml_translation['content'].present?

      parent_element.add_child(ng_element)
    end

    # Creates Nokogiri element object
    def create_ng_element(xml_translation, document)
      element_name = xml_translation.fetch('element', nil)
      validate_present element_name, "element key"
      document.create_element(element_name)
    end

    # Creates element content if data is available
    def generate_ng_element_content(dynamic_fields_groups_map, df_data, ng_element, content)
      # Allow for string value as a shortcut for [{'val' => 'some string'}]
      # Allow for array of strings as a shortcut for [{'val' => 'some string'}, {'val' => 'some other string'}]
      Array.wrap(content).map { |c| c.is_a?(Hash) ? c : { 'val' => c } }.each do |value|
        value['val'] = generate_field_val(value, df_data)
        if value.key?('yield') # Yield to dynamic_field_group renderer logic
          yield_to_string_key = value['yield']

          if dynamic_fields_groups_map.key?(yield_to_string_key) && df_data[yield_to_string_key].present?
            Array.wrap(dynamic_fields_groups_map[yield_to_string_key]).each do |translation_logic_rules|
              df_data[yield_to_string_key].each do |single_dynamic_field_group_data_value_for_string_key|
                Array.wrap(translation_logic_rules).each do |translation_logic_rule|
                  self.class.new(generator).generate(translation_logic_rule, single_dynamic_field_group_data_value_for_string_key, ng_element)
                end
              end
            end
          end
        elsif value.key?('element') # Create new child element
          self.class.new(generator).generate(value, df_data, ng_element)
        elsif value.key?('val') # Render string value in next text node, performing DynamicField value substitution for variables
          processed_val = value_with_substitutions(value['val'], df_data)
          ng_element.add_child(Nokogiri::XML::Text.new(processed_val, ng_element.document))
        end
      end
    end

    # Add attributes (including namespace definitions) to this element
    def add_attributes(xml_translation, df_data, ng_element)
      xml_translation['attrs']&.each do |attr_key, attr_val|
        next unless render?(attr_val['render_if'], df_data)

        val = generate_field_val(attr_val, df_data)
        val.strip! if val.respond_to?(:strip!)

        next if val.blank?

        if attr_key.start_with?('xmlns')
          # Do not treat xmlns attribute additions like other attribute additions.  Add namespace definition instead.
          ng_element.add_namespace_definition(attr_key.gsub(/^xmlns:/, ''), val)
        else
          processed_val = value_with_substitutions(val, df_data)
          ng_element.set_attribute(attr_key, processed_val) unless processed_val.blank?
        end
      end
    end

    # Ensure that the render conditions are a Hash
    def render?(render_if, df_data)
      render_if.is_a?(Hash) ? evaluate_conditions(render_if, df_data) : true
    end

    def evaluate_conditions(conditions, df_data)
      # Check for DynamicFieldGroup existence and DynamicField non-blank value
      conditions['present']&.each do |field_or_field_group|
        return false if !df_data[field_or_field_group].is_a?(Array) && value_for_field_name(field_or_field_group, df_data).blank?
      end

      # Check for DynamicFieldGroup existence and DynamicField blank value
      conditions['absent']&.each do |field_or_field_group|
        return false if df_data[field_or_field_group].present? || value_for_field_name(field_or_field_group, df_data).present?
      end

      # Comparison value given in xml_translation cannot be blank when using
      # equals/not_equals conditionals. Instead absent/present conditionals
      # should be used. Additionally, blank field values are never stored.

      conditions['equal']&.each do |field_string_key, value_to_compare_to|
        validate_present value_to_compare_to, "comparison value"
        return false if value_for_field_name(field_string_key, df_data) != value_to_compare_to
      end

      conditions['not_equal']&.each do |field_string_key, value_to_compare_to|
        validate_present value_to_compare_to, "comparison value"
        return false if value_for_field_name(field_string_key, df_data) == value_to_compare_to
      end

      true
    end
  end
end
