# frozen_string_literal: true

class DynamicFieldCategory < ActiveRecord::Base
  include DynamicFieldStructure::Sortable

  enum metadata_form: { descriptive: 0, item_rights: 1, asset_rights: 2 }

  has_many :dynamic_field_groups, as: :parent

  validates :display_label, presence: true, uniqueness: true
  validates :metadata_form, presence: true

  def as_json(_options = {})
    {
      id: id,
      type: self.class.name,
      display_label: display_label,
      sort_order: sort_order,
      children: dynamic_field_groups
    }
  end

  def children
    dynamic_field_groups.order(sort_order: :asc)
  end

  def siblings
    DynamicFieldCategory.unscoped.where.not(id: id)
  end
end
