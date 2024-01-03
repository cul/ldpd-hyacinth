require 'securerandom'

class AddUuidAndDataFilePathToDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    change_table(:digital_object_records) do |t|
      t.string :uuid, null: true, length: 36
      t.string :data_file_path, null: true, length: 1000
    end

    add_index :digital_object_records, :uuid, unique: true
  end
end
