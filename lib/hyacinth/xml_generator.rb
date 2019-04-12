module Hyacinth
  class XMLGenerator
    attr_reader :dynamic_fields_groups_map, :internal_fields, :document

    def initialize(digital_object_data, base_xml_translation, dynamic_fields_groups_map, internal_fields = {})
      @dynamic_fields_groups_map = dynamic_fields_groups_map # Map of dynamic field group keys to their xml_translation
      @base_xml_translation = base_xml_translation
      @digital_object_data = digital_object_data
      @internal_fields = internal_fields
    end

    def generate
      @document = Nokogiri::XML::Document.new
      Element.new(self).generate(@base_xml_translation, @digital_object_data, @document)
      recursively_remove_blank_xml_elements!(@document)
      @document
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
        break if empty_nodes.empty?
        break if empty_nodes.length == 1 && empty_nodes.first == root_node

        # Otherwise, delete empty nodes (except for the root node).
        empty_nodes.each { |node| node.remove if node != root_node }
      end
    end
  end
end
