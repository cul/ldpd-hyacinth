module DigitalObject::XmlDatastreamRendering
  extend ActiveSupport::Concern
  included do
    include DigitalObject::DynamicField::ValueResolution
  end

  def render_xml_datastream(xml_datastream)
    base_translation_logic = JSON(xml_datastream.xml_translation)

    @ng_xml_doc = Nokogiri::XML::Document.new
    dynamic_field_group_string_keys_to_objects = Hash[DynamicFieldGroup.all.map { |dfg| [dfg.string_key, dfg] }]
    render_xml_translation_with_data(@ng_xml_doc, @ng_xml_doc, base_translation_logic, dynamic_field_data, dynamic_field_group_string_keys_to_objects)

    # Clean up any elements with empty inner content and all-empty attributes
    recursively_remove_blank_xml_elements!(@ng_xml_doc)

    @ng_xml_doc.to_xml(indent: 2)
  end

  def should_render?(xml_translation_logic, df_data)
    # First, check for presence of "render_if" key, which will determine whether we should return immediately.
    return true unless xml_translation_logic['render_if'].present?
    stop = nil

    render_if_logic = xml_translation_logic['render_if']

    stop ||= render_if_logic.fetch('present', []).detect do |field_or_field_group_to_check_for|
      # Check for DynamicFieldGroup existence and DynamicField non-blank value
      df_data[field_or_field_group_to_check_for].blank? && value_for_field_name(field_or_field_group_to_check_for, df_data).blank?
    end

    stop ||= render_if_logic.fetch('absent', []).detect do |field_or_field_group_to_check_for|
      # Check for DynamicFieldGroup existence and DynamicField blank value
      df_data[field_or_field_group_to_check_for].present? || value_for_field_name(field_or_field_group_to_check_for, df_data).present?
    end

    stop ||= render_if_logic.fetch('equal', []).detect do |field_or_field_group_to_check_for, value_to_compare_to|
      value = value_for_field_name(field_or_field_group_to_check_for, df_data)
      value.blank? || value != value_to_compare_to
    end

    stop.nil?
  end

  def render_xml_translation_with_data(ng_xml_document, parent_element, xml_translation_logic, df_data, dynamic_field_group_string_keys_to_objects)
    return unless should_render?(xml_translation_logic, df_data)
    # Create new element
    element_name = xml_translation_logic['element'] || []

    new_element = @ng_xml_doc.create_element(element_name)

    # Add attributes (including namespace definitions) to this element
    attrs = xml_translation_logic['attrs'] || []
    attrs = attrs.map { |key, val| [key, resolve_value_hash(val, df_data)] }
    attrs = attrs.select { |_key, val| val['val'].present? }.map { |key, val| [key, val['val'].strip] }.to_h
    attrs.select { |key, val| key.start_with?('xmlns') && !val.blank? }.each do |key, val|
      # Do not treat xmlns attribute additions like other attribute additions.  Add namespace definition instead.
      new_element.add_namespace_definition(key.gsub(/^xmlns:/, ''), val)
    end
    attrs.reject { |key, _val| key.start_with?('xmlns') }.each do |key, val|
      processed_val = value_with_substitutions(val, df_data)
      new_element.set_attribute(key, processed_val) unless processed_val.blank?
    end

    yield_partitions = Array(xml_translation_logic['content']).map { |value| resolve_value_hash(value, df_data) }.partition { |value| value.key?('yield') }
    element_partitions = yield_partitions[1].partition { |value| value.key?('element') }
    values = elements[1]
    yield_partitions[0].select { |value| dynamic_field_group_string_keys_to_objects.key?(value['yield']) }.each do |value|
      # Yield to dynamic_field_group renderer logic
      dynamic_field_group_string_key = value['yield']

      dynamic_field_group_xml_translation_logic = JSON(dynamic_field_group_string_keys_to_objects[dynamic_field_group_string_key].xml_translation)
      df_data.fetch(dynamic_field_group_string_key, []).each do |dynamic_field_group_data_value|
        Array(dynamic_field_group_xml_translation_logic).each do |xml_translation_logic_rule|
          render_xml_translation_with_data(ng_xml_document, new_element, xml_translation_logic_rule, dynamic_field_group_data_value, dynamic_field_group_string_keys_to_objects)
        end
      end
    end
    element_partitions[0].each do |value|
      # Create new child element
      render_xml_translation_with_data(ng_xml_document, new_element, value, df_data, dynamic_field_group_string_keys_to_objects)
    end
    values.each do |value|
      # Render string value in next text node, performing DynamicField value substitution for variables
      # Example: "My favorite food is {{food}}!"
      processed_val = value_with_substitutions(value['val'], df_data)
      new_element.add_child Nokogiri::XML::Text.new(processed_val, ng_xml_document)
    end

    parent_element.add_child(new_element)
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
      empty_nodes.each { |node| node.remove if node != root_node }
    end
  end
end
