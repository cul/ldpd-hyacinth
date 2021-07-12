class ChangeDigitalObjectRecordsToDigitalObjects < ActiveRecord::Migration[6.0]
  def up
    add_timestamps :digital_object_records, null: true
    rename_table :digital_object_records, :digital_objects
    add_column :digital_objects, :type, :string, null: false, default: ''
    add_column :digital_objects, :first_published_at, :datetime
    add_column :digital_objects, :preserved_at, :datetime
    add_column :digital_objects, :first_preserved_at, :datetime
    add_column :digital_objects, :state, :integer, null: false, default: 0
    add_column :digital_objects, :doi, :string, null: true
    add_reference :digital_objects, :created_by, index: true
    add_reference :digital_objects, :updated_by, index: true
    add_column :digital_objects, :backup_metadata_location_uri, :string, length: 1000
  end
end
