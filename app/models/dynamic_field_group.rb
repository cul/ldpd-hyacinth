# frozen_string_literal: true

class DynamicFieldGroup < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey
  include DynamicFieldStructure::Path

  PARENT_TYPES = ['DynamicFieldCategory', 'DynamicFieldGroup'].freeze
  EXPORTABLE_ATTRIBUTES = [
    :id, :string_key, :display_label, :sort_order, :is_repeatable, :export_rules,
    :parent_type, :parent_id
  ].freeze

  has_many :dynamic_fields, dependent: :destroy
  has_many :export_rules, dependent: :destroy
  accepts_nested_attributes_for :export_rules

  has_many :dynamic_field_groups, as: :parent
  belongs_to :parent, polymorphic: true # DynamicFieldGroup or DynamicFieldCategory

  belongs_to :created_by, required: false, class_name: 'User'
  belongs_to :updated_by, required: false, class_name: 'User'

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

  def as_json(options = {})
    json = EXPORTABLE_ATTRIBUTES.map { |k| [k, self.send(k)] }.to_h
    json[:type] = self.class.name
    json[:children] = ordered_children.map(&:as_json)
    return json unless options[:camelize]
    json.deep_transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
    json
  end

  private

    def non_circular_relationship
      errors.add(:parent, 'cannot be self') if (parent_type == self.class.name) && (parent_id == id)
    end
end
