class ExportRule < ApplicationRecord
  include FieldExport::TranslationLogic

  belongs_to :dynamic_field_group
  belongs_to :field_export_profile

  before_validation :set_default_translation_logic

  validates :dynamic_field_group_id, uniqueness: {
    scope: :field_export_profile_id, message: ->(object, _) { "Dynamic field group already has an export rule for #{object.field_export_profile.name}" }
  }

  # TODO: Add validation that checks xml_translation against a json schema definition, for example.

  def as_json(_options = {})
    {
      id: id,
      translation_logic: translation_logic,
      field_export_profile: field_export_profile.name
    }
  end

  private

    def set_default_translation_logic
      self.translation_logic = [].to_json if translation_logic.blank?
    end
end
