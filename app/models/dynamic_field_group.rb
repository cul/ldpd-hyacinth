class DynamicFieldGroup < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey

  PARENT_TYPES = ['DynamicFieldCategory', 'DynamicFieldGroup'].freeze

  default_scope { order(sort_order: :asc) }

  has_many :dynamic_fields

  has_many :dynamic_field_groups, as: :parent
  belongs_to :parent, polymorphic: true # DynamicFieldGroup or DynamicFieldCategory

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  before_save :set_default_xml_translation, :clean_up_json_fields

  validates :display_label, presence: true
  validates :parent_id,     presence: true, numericality: { only_integer: true }
  validates :parent_type,   presence: true, inclusion: { in: PARENT_TYPES }
  validates :xml_translation, valid_json: true

  # Order children first by sort_order and then by string_key to break up ties.
  def ordered_children
    children.sort_by { |c| [c.sort_order, c.string_key] }
  end

  def children
    dynamic_field_groups + dynamic_fields
  end

  def siblings
    parent.respond_to?(:children) ? parent.children : []
  end

  def as_json(_options = {})
    {
      type: self.class.name,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      is_repeatable: is_repeatable,
      children: ordered_children,
      xml_translation: xml_translation
    }
  end

  private

    def set_default_xml_translation
      self.xml_translation = [].to_json if xml_translation.blank?
    end

    def clean_up_json_fields
      self.xml_translation = JSON.pretty_generate(JSON(xml_translation), indent: '    ')
    end
end
