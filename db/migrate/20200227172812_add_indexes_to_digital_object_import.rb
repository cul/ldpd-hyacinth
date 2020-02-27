class AddIndexesToDigitalObjectImport < ActiveRecord::Migration[6.0]
  def change
    add_index :digital_object_imports, :status
    add_index :digital_object_imports, :index
    add_index :digital_object_imports, [:batch_import_id, :status]
  end
end
