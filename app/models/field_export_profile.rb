class FieldExportProfile < ApplicationRecord
  include FieldExport::TranslationLogic

  has_many :export_rules, dependent: :destroy

  before_save :prettify_json

  validates :name, presence: true
end
