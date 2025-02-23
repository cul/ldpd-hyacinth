class AddDefaultStorageTypeToProjects < ActiveRecord::Migration[6.1]
  def change
    change_table(:projects) do |t|
      t.string :default_storage_type, null: false, default: Hyacinth::Storage::STORAGE_SCHEMES.first
    end
  end
end
