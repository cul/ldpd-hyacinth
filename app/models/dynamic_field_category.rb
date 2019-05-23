class DynamicFieldCategory < ActiveRecord::Base
  include DynamicFieldStructure::Sortable

  has_many :dynamic_field_groups, as: :parent

  validates :display_label, presence: true, uniqueness: true

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
    dynamic_field_groups
  end

  def siblings
    DynamicFieldCategory.where.not(id: id)
  end
end
