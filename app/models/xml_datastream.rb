class XmlDatastream < ActiveRecord::Base

  validate :validate_json_fields
  before_save :prettify_json

  def prettify_json
    self.xml_translation = JSON.pretty_generate(JSON(self.xml_translation))
  end

  # Validations
  def validate_json_fields
    if self.xml_translation.present? && ! Hyacinth::Utils::JsonUtils.valid_json?(self.xml_translation)
      errors.add(:xml_translation, "does not validate as JSON.  Value: " + self.xml_translation.to_s)
    end
  end

end
