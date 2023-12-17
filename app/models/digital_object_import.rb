class DigitalObjectImport < ApplicationRecord
  enum status: { pending: 0, success: 1, failure: 2 }
  serialize :digital_object_errors, Array
  serialize :prerequisite_csv_row_numbers, Array
  belongs_to :import_job, required: true
end
