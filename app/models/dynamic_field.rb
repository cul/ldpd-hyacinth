class DynamicField < ApplicationRecord
  include DynamicFieldAndDynamicFieldGroup::SharedValidations

  module Type
    STRING = 'string'
    TEXTAREA = 'textarea'
    INTEGER = 'integer'
    BOOLEAN = 'boolean'
    SELECT = 'select'
    DATE = 'date'
    CONTROLLED_TERM = 'controlled_term'
    VIEW_LIMITATION = 'view_limitation'
  end

  TYPES_TO_LABELS = {
    DynamicField::Type::STRING => 'String',
    DynamicField::Type::TEXTAREA => 'Textarea',
    DynamicField::Type::INTEGER => 'Integer',
    DynamicField::Type::BOOLEAN => 'Boolean',
    DynamicField::Type::SELECT => 'Select',
    DynamicField::Type::DATE => 'Date',
    DynamicField::Type::CONTROLLED_TERM => 'Controlled Term',
    DynamicField::Type::VIEW_LIMITATION => 'View Limitation'
  }

  belongs_to :parent_dynamic_field_group, class_name: 'DynamicFieldGroup'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  has_many :enabled_dynamic_fields, dependent: :destroy

  before_save :set_defaults_for_blank_fields

  validate :validate_dynamic_field_type, :validate_json_fields

  def as_json(_options = {})
    hash_to_return = {
      type: self.class.name,
      id: id,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      dynamic_field_type: dynamic_field_type,
      required_for_group_save: required_for_group_save
    }

    # Certain dynamic_field_types have additional data that should be sent as part of the json response
    if dynamic_field_type == self.class::Type::SELECT
      additional_data = self.additional_data
      hash_to_return[:select_options] = additional_data['select_options'].present? ? additional_data['select_options'] : {}
    elsif dynamic_field_type == self.class::Type::VIEW_LIMITATION
      hash_to_return[:view_limitation_options] = [
        {value: '', display_label: '- Default (none specified) -'},
        {value: 'full', display_label: 'Full Quality'},
        {value: 'reduced', display_label: 'Reduced Quality'}
      ]
    elsif dynamic_field_type == self.class::Type::CONTROLLED_TERM
      hash_to_return[:controlled_vocabulary] = {}
      controlled_vocabulary = ControlledVocabulary.find_by(string_key: controlled_vocabulary_string_key)
      hash_to_return[:controlled_vocabulary]['string_key'] = controlled_vocabulary_string_key
      hash_to_return[:controlled_vocabulary]['display_label'] = controlled_vocabulary.nil? ? 'Missing Vocabulary: ' + controlled_vocabulary_string_key : controlled_vocabulary.display_label
    end

    hash_to_return
  end

  def additional_data
    JSON(additional_data_json)
  end

  private

    def set_defaults_for_blank_fields
      # sort_order #
      if sort_order.blank?
        temp = parent_dynamic_field_group.dynamic_fields.order(sort_order: :desc).pluck(:sort_order)
        highest_sort_order = temp.blank? ? -1 : temp.first
        self.sort_order = highest_sort_order + 1
      end

      # additional_data_json #
      self.additional_data_json = {}.to_json if additional_data_json.blank?
    end

    # Validations

    def validate_dynamic_field_type
      validate_allowable
      validate_vocabulary if dynamic_field_type == DynamicField::Type::CONTROLLED_TERM
    end

    def validate_allowable
      errors.add(:dynamic_field_type, "is not an allowed value.") unless DynamicField::TYPES_TO_LABELS.keys.include?(dynamic_field_type)
    end

    def validate_vocabulary
      errors.add(:controlled_vocabulary_string_key, "cannot be blank for DynamicFields of type #{DynamicField::Type::CONTROLLED_TERM}.") if controlled_vocabulary_string_key.blank?
    end

    def validate_json_fields
      return unless additional_data_json.present?
      errors.add(:additional_data_json, "does not validate as JSON.") unless Hyacinth::Utils::JsonUtils.valid_json?(additional_data_json)
    end
end
