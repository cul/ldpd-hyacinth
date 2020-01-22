class RenameOpenToAllProjectsToShareableOnEnabledDynamicFields < ActiveRecord::Migration[6.0]
  def change
    rename_column :enabled_dynamic_fields, :open_to_all_projects, :shareable
  end
end
