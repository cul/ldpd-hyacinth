# frozen_string_literal: true

class ExportJob < ApplicationRecord
  after_destroy :delete_associated_file_if_exist

  belongs_to :user

  enum status: { pending: 0, in_progress: 1, success: 2, failure: 3, cancelled: 4 }
  serialize :export_errors, Array

  def delete_associated_file_if_exist
    Hyacinth::Config.export_job_storage.delete(file_location)
  end
end
