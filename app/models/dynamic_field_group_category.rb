class DynamicFieldGroupCategory < ActiveRecord::Base

  has_many :dynamic_field_groups

  before_save :set_sort_order_if_blank

  def as_json(options={})

    hash_to_return = {
      type: self.class.name,
      display_label: self.display_label,
      sort_order: self.sort_order,
      dynamic_field_groups: self.dynamic_field_groups
    }

    return hash_to_return
  end

  private

  def set_sort_order_if_blank
    if self.sort_order.blank?
      temp = DynamicFieldGroupCategory.order(:sort_order => :desc).pluck(:sort_order)
      new_sort_order = temp.blank? ? 0 : temp.first + 1
      self.sort_order = new_sort_order
    end
  end

end
