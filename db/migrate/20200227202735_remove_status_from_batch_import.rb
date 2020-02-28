class RemoveStatusFromBatchImport < ActiveRecord::Migration[6.0]
  def change
    remove_column :batch_imports, :status, :integer
    add_column :batch_imports, :cancelled, :boolean, null: false, default: false
  end
end
