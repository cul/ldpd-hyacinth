class DynamicField < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey

  module Type
    STRING = 'string'
    TEXTAREA = 'textarea'
    INTEGER = 'integer'
    BOOLEAN = 'boolean'
    SELECT = 'select'
    DATE = 'date'
    CONTROLLED_TERM = 'controlled_term'
  end

  TYPES_TO_LABELS = {
    DynamicField::Type::STRING => 'String',
    DynamicField::Type::TEXTAREA => 'Textarea',
    DynamicField::Type::INTEGER => 'Integer',
    DynamicField::Type::BOOLEAN => 'Boolean',
    DynamicField::Type::SELECT => 'Select',
    DynamicField::Type::DATE => 'Date',
    DynamicField::Type::CONTROLLED_TERM => 'Controlled Term'
  }

  # has_many :enabled_dynamic_fields, dependent: :destroy

  belongs_to :dynamic_field_group
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  before_save :set_default_for_additional_data

  validates :display_label,         presence: true
  validates :field_type,            presence: true, inclusion: { in: TYPES_TO_LABELS.keys }
  validates :controlled_vocabulary, presence: true, if: Proc.new { |d| d.field_type == Type::CONTROLLED_TERM }
  validates :select_options,        presence: true, if: Proc.new { |d| d.field_type == Type::SELECT }

  validates :additional_data_json, :select_options, valid_json: true

  def as_json(_options = {})
    hash = {
      type: self.class.name,
      id: id,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      field_type: field_type,
      required_for_group_save: required_for_group_save,
      select_options: select_options
    }

    if field_type == Type::CONTROLLED_TERM
      hash[:controlled_vocabulary] = { string_key: controlled_vocabulary, display_label: nil}
    end

    hash
  end

  def additional_data
    JSON(additional_data_json)
  end

  def siblings
    dynamic_field_group.respond_to?(:children) ? dynamic_field_group.children : []
  end

  private

    def set_default_for_additional_data
      self.additional_data_json = {}.to_json if additional_data_json.blank?
    end
end
