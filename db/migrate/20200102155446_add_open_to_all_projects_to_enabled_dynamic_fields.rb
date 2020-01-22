class AddOpenToAllProjectsToEnabledDynamicFields < ActiveRecord::Migration[6.0]
  def change
    add_column :enabled_dynamic_fields, :open_to_all_projects, :boolean, default: false, null: false
  end
end
