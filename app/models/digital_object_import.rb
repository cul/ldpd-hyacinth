class DigitalObjectImport < ActiveRecord::Base

  enum status: {pending: 0, success: 1, failure: 2}
  serialize :digital_object_errors, Array
  belongs_to :import_job, required: true

end
