# frozen_string_literal: true

class DigitalObjectImport < ApplicationRecord
  enum status: { pending: 0, in_progress: 1, success: 2, failure: 3 }

  serialize :import_errors, Array

  belongs_to :batch_import

  validates :status, :digital_object_data, presence: true
end
