class XmlDatastream < ApplicationRecord
  validates :string_key, presence: true, uniqueness: true, format: {
    with: /\A[a-zA-Z]+\z/,
    message: 'only allows letters (a-z, A-Z)'
  }
  validates :display_label, presence: true
  validates :xml_translation, presence: true

  validate :validate_json_fields
  before_save :prettify_json

  def prettify_json
    self.xml_translation = JSON.pretty_generate(JSON(xml_translation))
  end

  # Validations
  def validate_json_fields
    return unless xml_translation.present?

    errors.add(:xml_translation, "does not validate as JSON.  Value: #{xml_translation}") unless Hyacinth::Utils::JsonUtils.valid_json?(xml_translation)
  end
end
