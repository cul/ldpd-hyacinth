class AddOpenToAllProjectsToEnabledDynamicFields < ActiveRecord::Migration[5.2]
  def change
    add_column :enabled_dynamic_fields, :open_to_all_projects, :boolean, default: false, null: false
  end
end
