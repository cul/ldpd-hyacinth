require 'securerandom'

class RemoveDataFilePathFromDigitalObjectRecords < ActiveRecord::Migration
  def change
    remove_column :digital_object_records, :data_file_path
  end
end
