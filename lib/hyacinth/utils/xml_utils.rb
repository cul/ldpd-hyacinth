class Hyacinth::Utils::XmlUtils
  def self.replace_xml_subtrees(src_doc, dst_doc, xpaths_to_replace, namespaces = {})
    # TODO: first (before calling this method): build any missing xpaths if necessary (from xpaths_to_replace)

    # For backwards compatibility with Nokogiri versions < 1.12, we are reverting to the
    # 1.11-and-earlier default behavior of having namespace inheritance enabled for documents.
    # https://nokogiri.org/rdoc/Nokogiri/XML/Document#attribute-i-namespace_inheritance
    dst_doc.namespace_inheritance = true

    xpaths_to_replace.each do |subtree_xpath|
      src_subtree_nodes = src_doc.xpath(subtree_xpath, namespaces)
      dst_subtree_nodes = dst_doc.xpath(subtree_xpath, namespaces)

      parent_node = dst_subtree_nodes.first.parent

      # Remove all selected nodes from the dst doc that we want to modify at this subtree_xpath
      dst_subtree_nodes.each(&:remove)

      # Then add the src doc nodes to the parent node of the nodes you just removed
      src_subtree_nodes.each { |node| parent_node.add_child(node.to_xml) }
    end
  end
end
