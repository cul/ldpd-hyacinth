class DynamicFieldGroup < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey

  PARENT_TYPES = ['DynamicFieldCategory', 'DynamicFieldGroup'].freeze

  default_scope { order(sort_order: :asc) }

  has_many :dynamic_fields
  has_many :export_rules, dependent: :destroy
  accepts_nested_attributes_for :export_rules

  has_many :dynamic_field_groups, as: :parent
  belongs_to :parent, polymorphic: true # DynamicFieldGroup or DynamicFieldCategory

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  validates :display_label, presence: true
  validates :parent_id,     presence: true, numericality: { only_integer: true }
  validates :parent_type,   presence: true, inclusion: { in: PARENT_TYPES }
  validate  :non_circular_relationship

  # Order children first by sort_order and then by string_key to break up ties.
  def ordered_children
    children.sort_by { |c| [c.sort_order, c.string_key] }
  end

  def children
    dynamic_field_groups + dynamic_fields
  end

  def siblings
    parent.respond_to?(:children) ? parent.children.reject { |c| c.eql?(self) } : []
  end

  def as_json(_options = {})
    {
      id: id,
      type: self.class.name,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      is_repeatable: is_repeatable,
      children: ordered_children,
      export_rules: export_rules,
      parent_type: parent_type,
      parent_id: parent_id
    }
  end

  private

    def non_circular_relationship
      errors.add(:parent, 'cannot be self') if (parent_type == self.class.name) && (parent_id == id)
    end
end
