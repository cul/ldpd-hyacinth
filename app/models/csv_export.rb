class CsvExport < ActiveRecord::Base
  
  belongs_to :user
  
  enum status: {pending: 0, success: 1, failure: 2}
  serialize :export_errors, Array
  
end
