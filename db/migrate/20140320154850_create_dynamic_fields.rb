class CreateDynamicFields < ActiveRecord::Migration
  def change
    create_table :dynamic_fields do |t|
      t.string :string_key, index: true, null: false
      t.string :display_label, null: false
      t.references :parent_dynamic_field_group, index: true, null: true # References DynamicFieldGroup, specified in model
      t.integer :sort_order, null: false

      t.string :dynamic_field_type, null: false, default: DynamicField::Type::STRING
      t.references :controlled_vocabulary, index: true, null: true
      t.text :additional_data_json

      t.boolean :is_keyword_searchable, null: false, default: false
      t.boolean :is_facet_field, null: false, default: false
      t.boolean :required_for_group_save, null: false, default: false
      t.string :standalone_field_label, null: false, default: ''
      t.boolean :is_searchable_identifier_field, null: false, default: false
      t.boolean :is_searchable_title_field, null: false, default: false
      t.boolean :is_single_field_searchable, null: false, default: false

      t.references :created_by # References User, specified in model
      t.references :updated_by # References User, specified in model
      t.timestamps
    end

    add_index :dynamic_fields, [:string_key, :parent_dynamic_field_group_id], name: 'unique_string_key_and_parent_dynamic_field_group', unique: true # Allow same-name string keys, but not for DynamicFieldGroups that have the same parent_dynamic_field_group
  end
end
