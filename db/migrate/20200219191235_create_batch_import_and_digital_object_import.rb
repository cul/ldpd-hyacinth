class CreateBatchImportAndDigitalObjectImport < ActiveRecord::Migration[6.0]
  def change
    create_table :batch_imports do |t|
      t.belongs_to :user, index: true

      t.text       :file_location
      t.integer    :status, default: 0, null: false
      t.integer    :priority, default: 0, null: false

      t.timestamps
    end

    create_table :digital_object_imports do |t|
      t.belongs_to :batch_import, index: true

      t.text    :digital_object_data, null: false
      t.text    :import_errors
      t.integer :status, default: 0, null: false
      t.integer :index

      t.timestamps
    end
  end
end
