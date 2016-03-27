class CsvExport < ActiveRecord::Base
  
  after_destroy :delete_associated_file_if_exists
  
  belongs_to :user
  
  enum status: {pending: 0, success: 1, failure: 2}
  serialize :export_errors, Array
  
  def delete_associated_file_if_exists
    if self.path_to_csv_file.present? && File.exists?(self.path_to_csv_file)
        FileUtils.rm(self.path_to_csv_file)
    end
  end
end
