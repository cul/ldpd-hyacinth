class Hyacinth::Utils::XmlUtils
  def self.replace_xml_subtrees(src_doc, dst_doc, xpaths_to_replace, namespaces = {})
    # TODO: first (before calling this method): build any missing xpaths if necessary (from xpaths_to_replace)

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
