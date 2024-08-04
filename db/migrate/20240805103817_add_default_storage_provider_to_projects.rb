class AddDefaultStorageTypeToProjects < ActiveRecord::Migration[6.1]
  def change
    change_table(:projects) do |t|
      t.boolean :default_storage_type, null: false, default: 'file'
    end
  end
end
