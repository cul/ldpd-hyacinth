# frozen_string_literal: true

class ImportPrerequisite < ApplicationRecord
  # A digital_object_import actually is required on save, but it can be supplied as a
  # digital_object_import_id rather than a digital_object_import.
  belongs_to :digital_object_import, required: false
  belongs_to :batch_import
  belongs_to :prerequisite_digital_object_import, class_name: 'DigitalObjectImport'

  # Note, below, that we're requiring digital_object_import_id and prerequisite_digital_object_import_id
  # rather than digital_object_import and prerequisite_digital_object_import. This allows us to
  # create new records with just an id instead of having to retrieve an instance.
  validates :batch_import, :digital_object_import_id, :prerequisite_digital_object_import_id, presence: true
end
