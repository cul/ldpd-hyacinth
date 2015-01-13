class CreateDynamicFieldGroups < ActiveRecord::Migration
  def change
    create_table :dynamic_field_groups do |t|
      t.string :string_key, index: true, null: false
      t.string :display_label, null: false
      t.references :parent_dynamic_field_group, index: true, null: true # References DynamicFieldGroup, specified in model
      t.integer :sort_order, null: false
      t.boolean :is_repeatable, null: false, default: false

      # Fields for top level DynamicFieldGroups
      t.references :xml_datastream, index: true, null: true
      t.text :xml_translation_json
      t.integer :xml_extraction_priority, null: false, default: 0 # Higher priority groups will be extracted before other same-level groups.  Important for fields that map to overlapping xpath elements like /note[type="something"] and /note
      t.references :dynamic_field_group_category, null: true, index: true

      t.references :created_by # References User, specified in model
      t.references :updated_by # References User, specified in model
      t.timestamps
    end

    add_index :dynamic_field_groups, [:string_key, :parent_dynamic_field_group_id], name: 'unique_string_key_for_same_parent_dynamic_field_group', unique: true # Allow same-name string keys, but not for DynamicFieldGroups that have the same parent_dynamic_field_group
  end
end
