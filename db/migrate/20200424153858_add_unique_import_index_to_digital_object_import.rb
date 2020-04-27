class AddUniqueImportIndexToDigitalObjectImport < ActiveRecord::Migration[6.0]
  def change
    add_index :digital_object_imports, [:batch_import_id, :index], unique: true
  end
end
