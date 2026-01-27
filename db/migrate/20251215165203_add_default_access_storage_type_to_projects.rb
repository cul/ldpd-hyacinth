class AddDefaultAccessStorageTypeToProjects < ActiveRecord::Migration[7.0]
  def change
    change_table(:projects) do |t|
      t.string :default_access_storage_type, null: false, default: Hyacinth::Storage::STORAGE_SCHEMES.first
    end
  end
end
