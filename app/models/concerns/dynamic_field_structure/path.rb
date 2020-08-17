# frozen_string_literal: true

module DynamicFieldStructure
  module Path
    extend ActiveSupport::Concern

    included do |mod|
      mod.send :before_save, :assign_path
      mod.send :after_save, :queue_path_change_job
    end

    class_methods do
      def collect_ancestor_nodes(nodes, group_or_category)
        return nodes if group_or_category.class == DynamicFieldCategory

        raise ArgumentError, 'Must respond to #parent in order to collect path' unless group_or_category.respond_to?(:parent)
        parent = group_or_category.parent
        collect_ancestor_nodes(nodes.unshift(parent), parent)
      end
    end

    # @return [Array] ancestor dynamic field groups/categories, in branch-to-leaf order
    def ancestor_nodes
      self.class.collect_ancestor_nodes([], self)
    end

    def assign_path(force = false)
      return unless string_key_changed? || path.nil? || force
      self.path = calculate_path
    end

    def assign_path!(force = false)
      assign_path(force)
      save
    end

    # queue job to change paths if string_key changed
    # trigger from string_key to prevent race conditions among descendants.
    def queue_path_change_job
      return unless previous_changes['string_key'].present?
      previous_changes['path'].tap { |arr| ChangeDynamicFieldPathsJob.perform(arr[0] => arr[1]) }
    end

    private

      def calculate_path
        (ancestor_nodes[1..-1].map(&:string_key) << self.string_key).join('/')
      end
  end
end
