class CreateImportPrerequisites < ActiveRecord::Migration[6.0]
  def change
    # A DigitalObjectImport sometimes has import prerequisites (e.g. a new Item must be created
    # before a child Asset can be added to it). We need a way of expressing these dependencies
    # so we process DigitalObjectImports in the correct order and don't queue them until they're
    # ready to be processed.
    create_table :import_prerequisites do |t|
      t.belongs_to :digital_object_import, index: true
      t.belongs_to :prerequisite_digital_object_import, index: { name: 'prerequisite_digital_object_import_id' }

      t.belongs_to :batch_import, index: true

      # only need created_at, so we're specifying it here and omitting updated_at
      t.datetime :created_at, null: false
    end

    add_index :import_prerequisites, [
      :batch_import_id,
      :digital_object_import_id,
      :prerequisite_digital_object_import_id
    ], unique: true, name: 'unique_import_prerequisite'
  end
end
