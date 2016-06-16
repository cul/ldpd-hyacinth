class DynamicFieldGroupCategory < ActiveRecord::Base
  has_many :dynamic_field_groups

  before_save :set_sort_order_if_blank

  def as_json(_options = {})
    {
      type: self.class.name,
      display_label: display_label,
      sort_order: sort_order,
      dynamic_field_groups: dynamic_field_groups
    }
  end

  private

    def set_sort_order_if_blank
      return unless sort_order.blank?

      temp = DynamicFieldGroupCategory.order(sort_order: :desc).pluck(:sort_order)
      new_sort_order = temp.blank? ? 0 : temp.first + 1
      self.sort_order = new_sort_order
    end
end
