module DigitalObject::XmlDatastreamRendering
  extend ActiveSupport::Concern

  def render_xml_datastream(xml_datastream)

    base_translation_logic = JSON(xml_datastream.xml_translation)

    @ng_xml_doc = Nokogiri::XML::Document.new
    dynamic_field_group_string_keys_to_objects = Hash[DynamicFieldGroup.all.map{|dfg| [dfg.string_key, dfg]}]
    render_xml_translation_with_data(@ng_xml_doc, @ng_xml_doc, base_translation_logic, self.dynamic_field_data, dynamic_field_group_string_keys_to_objects)

    # Clean up any elements with empty inner content and all-empty attributes
    recursively_remove_blank_xml_elements!(@ng_xml_doc)

    return @ng_xml_doc.to_xml(:indent => 2)
  end

  def render_xml_translation_with_data(ng_xml_document, parent_element, xml_translation_logic, df_data, dynamic_field_group_string_keys_to_objects)

    # First, check for presence of "render_if" key, which will determine whether we should return immediately.
    if xml_translation_logic['render_if'].present?
      render_if_logic = xml_translation_logic['render_if']

      if render_if_logic['present'].present?
        render_if_logic['present'].each do |field_or_field_group_to_check_for|
          # Check for DynamicFieldGroup existence and DynamicField non-blank value
          return unless df_data[field_or_field_group_to_check_for].is_a?(Array) || value_for_field_name(field_or_field_group_to_check_for, df_data).present?
        end
      end

      if render_if_logic['absent'].present?
        render_if_logic['absent'].each do |field_or_field_group_to_check_for|
          # Check for DynamicFieldGroup existence and DynamicField blank value
          return unless df_data[field_or_field_group_to_check_for].nil? && value_for_field_name(field_or_field_group_to_check_for, df_data).blank?
        end
      end

      if render_if_logic['equal'].present?
        render_if_logic['equal'].each_pair do |field_string_key, value_to_compare_to|
          value = value_for_field_name(field_string_key, df_data)
          return unless value.present? && value == value_to_compare_to
        end
      end

    end

    # Create new element
    element_name = xml_translation_logic['element'] || []

    new_element = ng_xml_document.create_element(element_name)

    # Add attributes (including namespace definitions) to this element
    attrs = xml_translation_logic['attrs'] || []
    if attrs.present?
      attrs.each do |attr_key, attr_val|

        # Allow for string value as a shortcut for {'val' => 'some string'}
        if attr_val.is_a?(String)
          attr_val = {'val' => attr_val}
        else
          # The output of a ternary evaluation gets placed in a {'val' => 'some value'}, so the normal 'val' evaluation code still runs.
          if attr_val['ternary'].present?
            attr_val['val'] = render_output_of_ternary(attr_val['ternary'], df_data)
          elsif attr_val['join'].present?
            attr_val['val'] = render_output_of_join(attr_val['join'], df_data)
          end
        end

        if attr_val['val'].present?
          trimmed_val = attr_val['val'].strip
          if attr_key.start_with?('xmlns')
            # Do not treat xmlns attribute additions like other attribute additions.  Add namespace definition instead.
            new_element.add_namespace_definition(attr_key.gsub(/^xmlns:/, ''), trimmed_val) unless trimmed_val.blank?
          else
            processed_val = value_with_substitutions(trimmed_val, df_data)
            new_element.set_attribute(attr_key, processed_val) unless processed_val.blank?
          end
        end

      end
    end

    # Add child content
    content = xml_translation_logic['content']

    # Allow for string value as a shortcut for [{'val' => 'some string'}]
    if content.is_a?(String)
      content = [{'val' => content}]
    end

    if content.present?
      content.each do |value|

        # Array elements that are strings will be treated like val objects: {'val' => 'some string'}
        if value.is_a?(String)
          value = {'val' => value}
        else
          # The output of a ternary evaluation gets placed in a {'val' => 'some value'}, so the normal 'val' evaluation code still runs.
          if value['ternary'].present?
            value['val'] = render_output_of_ternary(value['ternary'], df_data)
          elsif value['join'].present?
            value['val'] = render_output_of_join(value['join'], df_data)
          end
        end

        if value.has_key?('yield')
          # Yield to dynamic_field_group renderer logic
          dynamic_field_group_string_key = value['yield']

          if dynamic_field_group_string_keys_to_objects.has_key?(dynamic_field_group_string_key)
            xml_translation_logic_for_dynamic_field_group_string_key = JSON(dynamic_field_group_string_keys_to_objects[dynamic_field_group_string_key].xml_translation)
            unless df_data[dynamic_field_group_string_key].blank?
              df_data[dynamic_field_group_string_key].each do |single_dynamic_field_group_data_value_for_string_key|
                unless xml_translation_logic_for_dynamic_field_group_string_key.is_a?(Array)
                  xml_translation_logic_for_dynamic_field_group_string_key = [xml_translation_logic_for_dynamic_field_group_string_key]
                end
                xml_translation_logic_for_dynamic_field_group_string_key.each do |xml_translation_logic_rule|
                  render_xml_translation_with_data(ng_xml_document, new_element, xml_translation_logic_rule, single_dynamic_field_group_data_value_for_string_key, dynamic_field_group_string_keys_to_objects)
                end
              end
            end
          end
        elsif value.has_key?('element')
          # Create new child element
          render_xml_translation_with_data(ng_xml_document, new_element, value, df_data, dynamic_field_group_string_keys_to_objects)
        elsif value.has_key?('val')
          # Render string value in next text node, performing DynamicField value substitution for variables
          #Example: "My favorite food is {{food}}!"
          processed_val = value_with_substitutions(value['val'], df_data)
          new_element.add_child( Nokogiri::XML::Text.new(processed_val, ng_xml_document) )
        end
      end
    end

    parent_element.add_child(new_element)
  end

  # Captures everything between the {{}} and replaces it with the value provided in the df_data map.
  # Converts value found to string, incase we're working with a numeric or boolean value.
  def value_with_substitutions(value, df_data)
    value.gsub(/(\{\{(?:(?!\}\}).)+\}\})/) do |sub|
      value_for_field_name(sub[2, sub.length-4], df_data).to_s
    end
  end

  def value_for_field_name(field_name, df_data)
    if field_name.start_with?('$')
      # Then this is a special substitution that we handle differently.
      # We only allow certain fields
      if field_name == '$project.display_label'
        self.project.display_label
      elsif field_name == '$project.short_label'
        self.project.short_label.present? ? self.project.short_label : self.project.display_label
      elsif field_name == '$project.uri'
        self.project.uri.present? ? self.project.uri : ''
      elsif field_name == '$created_at'
        created_at.iso8601
      elsif field_name == '$updated_at'
        updated_at.iso8601
      elsif field_name == '$doi'
        # slice off the "doi:" label
        doi.present? ? doi.sub(/^doi:/, '') : ''
      else
        'Data unavailable'
      end
    elsif df_data.has_key?(field_name) && ! df_data[field_name].is_a?(Array)
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
    pieces.delete_if(&:blank?).join(delimiter)
  end

  def recursively_remove_blank_xml_elements!(ng_xml_doc)
    # The result of this method is a recursive removal, but I'm actually using a loop + xpath to do the removal because it's more straightforward.
    root_node = ng_xml_doc.root

    # First, clear all self closing tags without any attributes.  These cause xpath selection problems when we're looking for empty nodes.
    # Search for empty nodes and delete them.  Continue searching for and removing empty nodes until no more are found.
    loop do
      empty_nodes = ng_xml_doc.xpath('//*[(text() = "" or not(node())) and not(@*)]')

      # If no empty nodes are found, we're done.
      # If only one empty node was found and it's the root node, we're done.
      break if empty_nodes.length == 0
      break if empty_nodes.length == 1 && empty_nodes.first == root_node

      # Otherwise, delete empty nodes (except for the root node).
      empty_nodes.each do |node|
        if node != root_node
          node.remove
        end
      end
    end
  end

end
