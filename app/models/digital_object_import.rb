class DigitalObjectImport < ApplicationRecord
  enum :status, { pending: 0, success: 1, failure: 2 }
  serialize :digital_object_errors, type: Array, coder: YAML
  serialize :prerequisite_csv_row_numbers, type: Array, coder: YAML
  belongs_to :import_job
end
