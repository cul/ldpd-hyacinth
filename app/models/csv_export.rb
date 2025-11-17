class CsvExport < ApplicationRecord
  after_destroy :delete_associated_file_if_exists

  belongs_to :user

  enum :status, { pending: 0, success: 1, failure: 2 }
  serialize :export_errors, Array

  def delete_associated_file_if_exists
    FileUtils.rm(path_to_csv_file) if path_to_csv_file.present? && File.exist?(path_to_csv_file)
  end
end
