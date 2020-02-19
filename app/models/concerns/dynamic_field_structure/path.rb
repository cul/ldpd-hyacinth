# frozen_string_literal: true

module DynamicFieldStructure
  module Path
    extend ActiveSupport::Concern

    def path
      collect_path([], self)
    end

    def collect_path(path, group_or_category)
      return path if group_or_category.class == DynamicFieldCategory

      parent = group_or_category.parent
      collect_path(path.unshift(parent), parent)
    end
  end
end
