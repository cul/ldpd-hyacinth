class CreateDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :digital_object_records do |t|
      t.string :pid, unique: true
      t.references :created_by
      t.references :updated_by
      t.timestamps
    end

    add_index :digital_object_records, :pid, unique: true
  end
end
