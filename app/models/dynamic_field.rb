# frozen_string_literal: true

class DynamicField < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey
  include DynamicFieldStructure::Path

  module Type
    STRING = 'string'
    TEXTAREA = 'textarea'
    INTEGER = 'integer'
    BOOLEAN = 'boolean'
    SELECT = 'select'
    DATE = 'date'
    CONTROLLED_TERM = 'controlled_term'
  end

  TYPES = [Type::STRING, Type::TEXTAREA, Type::INTEGER, Type::BOOLEAN, Type::SELECT, Type::DATE, Type::CONTROLLED_TERM].freeze

  EXPORTABLE_ATTRIBUTES = [
    :id, :string_key, :display_label, :sort_order, :field_type, :filter_label, :select_options,
    :is_facetable, :is_keyword_searchable, :is_title_searchable, :is_identifier_searchable,
    :controlled_vocabulary
  ].freeze

  has_many :enabled_dynamic_fields, dependent: :destroy

  belongs_to :dynamic_field_group
  belongs_to :created_by, required: false, class_name: 'User'
  belongs_to :updated_by, required: false, class_name: 'User'

  before_save :set_default_for_additional_data

  validates :display_label,         presence: true
  validates :field_type,            presence: true, inclusion: { in: TYPES }
  validates :controlled_vocabulary, presence: true, if: proc { |d| d.field_type == Type::CONTROLLED_TERM }
  validates :select_options,        presence: true, if: proc { |d| d.field_type == Type::SELECT }
  validates :is_facetable,          inclusion: { in: [false], message: 'cannot be true for textareas' }, if: proc { |d| d.field_type == Type::TEXTAREA }
  validates :additional_data_json, :select_options, valid_json: true
  validates_with StringKey::AbsentInSiblingGroupsValidator

  def self.find_by_path_traversal(path)
    # There are no top level DynamicFields.  Field must be under a DynamicFieldGroup.
    raise ActiveRecord::RecordNotFound, "Could not find a DynamicField at path: #{path.inspect}" if path.nil? || path.length < 2

    # Save a copy of the original path for potential error reporting later on
    original_path = path.dup

    current_node = DynamicFieldGroup.find_by!(string_key: path.shift)

    current_node = DynamicFieldGroup.find_by!(string_key: path.shift, dynamic_field_group: current_node) while path.length > 1

    DynamicField.find_by!(string_key: path.shift, dynamic_field_group: current_node)
  rescue ActiveRecord::RecordNotFound
    # Re-raise with more helpful error message
    raise ActiveRecord::RecordNotFound, "Could not find DynamicField at path: #{original_path.inspect}"
  end

  def as_json(options = {})
    json = EXPORTABLE_ATTRIBUTES.map { |k| [k, self.send(k)] }.to_h
    json[:type] = self.class.name
    return json unless options[:camelize]
    json.deep_transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
    json
  end

  def additional_data
    JSON(additional_data_json)
  end

  def siblings
    dynamic_field_group.respond_to?(:children) ? dynamic_field_group.children.reject { |c| c.eql?(self) } : []
  end

  def parent
    dynamic_field_group
  end

  private

    def set_default_for_additional_data
      self.additional_data_json = {}.to_json if additional_data_json.blank?
    end
end
