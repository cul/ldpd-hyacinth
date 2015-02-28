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

  def render_xml_translation_with_data(ng_xml_document, parent_element, xml_translation_logic, dynamic_field_data, dynamic_field_group_string_keys_to_objects)

    # Create new element
    element_name = xml_translation_logic['element'] || []

    new_element = @ng_xml_doc.create_element(element_name)

    # Add attributes (including namespace definitions) to this element
    attrs = xml_translation_logic['attrs'] || []
    if attrs.present?
      attrs.each do |attr_key, attr_val|

        # Allow for string value as a shortcut for {'val' => 'some string'}
        if attr_val.is_a?(String)
          attr_val = {'val' => attr_val}
        end

        if attr_val['val']
          trimmed_val = attr_val['val'].strip
          if attr_key.start_with?('xmlns')
            # Do not treat xmlns attribute additions like other attribute additions.  Add namespace definition instead.
            new_element.add_namespace_definition(attr_key.gsub(/^xmlns:/, ''), trimmed_val) unless trimmed_val.blank?
          else
            processed_val = render_value_with_substitutions(trimmed_val, dynamic_field_data)
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
        end

        if value.has_key?('yield')
          # Yield to dynamic_field_group renderer logic
          dynamic_field_group_string_key = value['yield']

          xml_translation_logic_for_dynamic_field_group_string_key = JSON(dynamic_field_group_string_keys_to_objects[dynamic_field_group_string_key].xml_translation)
          unless dynamic_field_data[dynamic_field_group_string_key].blank?
            dynamic_field_data[dynamic_field_group_string_key].each do |single_dynamic_field_group_data_value_for_string_key|
              unless xml_translation_logic_for_dynamic_field_group_string_key.is_a?(Array)
                xml_translation_logic_for_dynamic_field_group_string_key = [xml_translation_logic_for_dynamic_field_group_string_key]
              end
              xml_translation_logic_for_dynamic_field_group_string_key.each do |xml_translation_logic_rule|
                render_xml_translation_with_data(ng_xml_document, new_element, xml_translation_logic_rule, single_dynamic_field_group_data_value_for_string_key, dynamic_field_group_string_keys_to_objects)
              end
            end
          end
        elsif value.has_key?('element')
          # Create new child element
          render_xml_translation_with_data(ng_xml_document, new_element, value, dynamic_field_data, dynamic_field_group_string_keys_to_objects)
        elsif value.has_key?('val')
          # Render string value in next text node, performing DynamicField value substitution for variables
          #Example: "My favorite food is {{food}}!"
          processed_val = render_value_with_substitutions(value['val'], dynamic_field_data)
          new_element.add_child( Nokogiri::XML::Text.new(processed_val, ng_xml_document) )
        end
      end
    end

    parent_element.add_child(new_element)
  end

  def render_value_with_substitutions(value, dynamic_field_data)
    value.gsub(/(\{\{(?:(?!\}\}).)+\}\})/) do |sub|
      sub_without_braces = sub[2, sub.length-4]
      if sub_without_braces.start_with?('$')
        # Then this is a special substitution that we handle differently.
        if sub_without_braces == '$project.display_label'
          self.projects.first.display_label
        else
          ''
        end
      elsif ! dynamic_field_data[sub_without_braces].is_a?(Array) && dynamic_field_data.has_key?(sub_without_braces)
        dynamic_field_data[sub_without_braces]
      else
        ''
      end
    end
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
