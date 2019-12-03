# frozen_string_literal: true

module DynamicFieldStructure
  module Sortable
    extend ActiveSupport::Concern

    included do
      before_validation :set_sort_order
      validates :sort_order, presence: true
    end

    private

      def set_sort_order
        return unless sort_order.blank?

        highest_sort_order = siblings.map(&:sort_order).max
        self.sort_order = highest_sort_order.blank? ? 0 : highest_sort_order + 1
      end
  end
end
