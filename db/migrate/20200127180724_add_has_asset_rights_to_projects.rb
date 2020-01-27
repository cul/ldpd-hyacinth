class AddHasAssetRightsToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :has_asset_rights, :boolean, default: false, null: false
  end
end
