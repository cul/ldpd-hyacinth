# frozen_string_literal: true

module DynamicFieldStructure
  module Path
    extend ActiveSupport::Concern

    class_methods do
      def collect_path(path, group_or_category)
        return path if group_or_category.class == DynamicFieldCategory

        raise ArgumentError, 'Must respond to #parent in order to collect path' unless group_or_category.respond_to?(:parent)
        parent = group_or_category.parent
        collect_path(path.unshift(parent), parent)
      end
    end

    def path
      self.class.collect_path([], self)
    end
  end
end
