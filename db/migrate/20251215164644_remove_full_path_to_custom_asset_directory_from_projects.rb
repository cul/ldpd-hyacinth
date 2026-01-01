class RemoveFullPathToCustomAssetDirectoryFromProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :full_path_to_custom_asset_directory
  end
end
