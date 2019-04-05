class FieldExportProfile < ApplicationRecord
  include FieldExport::TranslationLogic

  has_many :export_rules

  before_save :prettify_json

  validates :name, presence: true
end
