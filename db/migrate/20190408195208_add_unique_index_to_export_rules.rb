class AddUniqueIndexToExportRules < ActiveRecord::Migration[5.2]
  def change
    add_index :export_rules, [:field_export_profile_id, :dynamic_field_group_id], unique: true, name: 'index_export_rules_on_export_profile_and_dynamic_field_group'
  end
end
