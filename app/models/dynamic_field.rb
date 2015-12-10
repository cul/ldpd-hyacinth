class DynamicField < ActiveRecord::Base

  include DynamicFieldAndDynamicFieldGroup::SharedValidations

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
    DynamicField::Type::CONTROLLED_TERM => 'Controlled Term',
  }

  belongs_to :parent_dynamic_field_group, class_name: 'DynamicFieldGroup'
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  before_save :set_defaults_for_blank_fields

  validate :validate_dynamic_field_type, :validate_json_fields

  def as_json(options={})

    hash_to_return = {
      type: self.class.name,
      id: self.id,
      string_key: self.string_key,
      display_label: self.display_label,
      sort_order: self.sort_order,
      dynamic_field_type: self.dynamic_field_type,
      required_for_group_save: self.required_for_group_save
    }

    # Certain dynamic_field_types have additional data that should be sent as part of the json response
    if dynamic_field_type == self.class::Type::SELECT
      additional_data = self.get_additional_data
      hash_to_return[:select_options] = additional_data['select_options'].present? ? additional_data['select_options'] : {}
    elsif dynamic_field_type == self.class::Type::CONTROLLED_TERM
      hash_to_return[:controlled_vocabulary] = {}
      controlled_vocabulary = ControlledVocabulary.find_by(string_key: self.controlled_vocabulary_string_key)
      hash_to_return[:controlled_vocabulary]['string_key'] = self.controlled_vocabulary_string_key
      hash_to_return[:controlled_vocabulary]['display_label'] = controlled_vocabulary.nil? ? 'Missing Vocabulary: ' + controlled_vocabulary_string_key : controlled_vocabulary.display_label
    end

    return hash_to_return
  end

  def get_additional_data
    return JSON(self.additional_data_json)
  end

  private

  def set_defaults_for_blank_fields
    # sort_order #
    if self.sort_order.blank?
      temp = self.parent_dynamic_field_group.dynamic_fields.order(:sort_order => :desc).pluck(:sort_order)
      highest_sort_order = temp.blank? ? -1 : temp.first
      self.sort_order = highest_sort_order + 1
    end

    # additional_data_json #
    self.additional_data_json = {}.to_json if self.additional_data_json.blank?
  end

  # Validations

  def validate_dynamic_field_type
    unless DynamicField::TYPES_TO_LABELS.keys.include?(self.dynamic_field_type)
      errors.add(:dynamic_field_type, "is not an allowed value.")
    end
    if self.dynamic_field_type == DynamicField::Type::CONTROLLED_TERM && self.controlled_vocabulary_string_key.blank?
      errors.add(:controlled_vocabulary_string_key, "cannot be blank for DynamicFields of type " + DynamicField::Type::CONTROLLED_TERM + '.')
    end
  end

  def validate_json_fields
    if self.additional_data_json.present? && ! Hyacinth::Utils::JsonUtils.valid_json?(self.additional_data_json)
      errors.add(:additional_data_json, "does not validate as JSON.")
    end
  end

end
