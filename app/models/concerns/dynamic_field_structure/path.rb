# frozen_string_literal: true

module DynamicFieldStructure
  module Path
    extend ActiveSupport::Concern

    class_methods do
      def collect_ancestor_nodes(path, group_or_category)
        return path if group_or_category.class == DynamicFieldCategory

        raise ArgumentError, 'Must respond to #parent in order to collect path' unless group_or_category.respond_to?(:parent)
        parent = group_or_category.parent
        collect_ancestor_nodes(path.unshift(parent), parent)
      end
    end

    # @return [Array] ancestor dynamic field groups/categories, in branch-to-leaf order
    def ancestor_nodes
      self.class.collect_ancestor_nodes([], self)
    end
  end
end
