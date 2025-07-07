class AddDigitalObjectDataLocationToDigitalObjectRecords < ActiveRecord::Migration[6.1]
  def change
    change_table(:digital_object_records) do |t|
      t.string :digital_object_data_location_uri, null: true, limit: 1000
    end
  end
end
