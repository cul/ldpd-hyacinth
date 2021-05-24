# frozen_string_literal: true

class DynamicFieldCategory < ActiveRecord::Base
  include DynamicFieldStructure::Sortable

  enum metadata_form: { descriptive: 0, item_rights: 1, asset_rights: 2 }

  has_many :dynamic_field_groups, as: :parent

  validates :display_label, presence: true, uniqueness: { message: "%{value} is already taken" }
  validates :metadata_form, presence: true

  def as_json(options = {})
    json = {
      id: id,
      type: self.class.name,
      display_label: display_label,
      sort_order: sort_order,
      children: children.map(&:as_json)
    }
    return json unless options[:camelize]
    json.deep_transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
    json
  end

  def children
    dynamic_field_groups.order(sort_order: :asc)
  end

  def siblings
    DynamicFieldCategory.unscoped.where.not(id: id)
  end
end
