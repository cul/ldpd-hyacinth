class AddPathAttributeToDynamicFieldStructureNodes < ActiveRecord::Migration[6.0]
  def change
    add_column :dynamic_fields, :path, :string, null: true
    add_index :dynamic_fields, :path, unique: true
    add_column :dynamic_field_groups, :path, :string, null: true
    add_index :dynamic_field_groups, :path, unique: true
  end
end
