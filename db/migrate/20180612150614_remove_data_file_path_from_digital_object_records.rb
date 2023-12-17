require 'securerandom'

class RemoveDataFilePathFromDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    remove_column :digital_object_records, :data_file_path
  end
end
