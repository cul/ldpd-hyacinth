# frozen_string_literal: true

class ImportPrerequisite < ApplicationRecord
  # A digital_object_import actually is required on save, but it can be supplied as a
  # digital_object_import_id rather than a digital_object_import.
  belongs_to :digital_object_import
  belongs_to :batch_import
  belongs_to :prerequisite_digital_object_import, class_name: 'DigitalObjectImport'
end
