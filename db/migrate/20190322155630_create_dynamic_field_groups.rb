class CreateDynamicFieldGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :dynamic_field_groups do |t|
      t.string   :string_key,    null: false
      t.string   :display_label, null: false
      t.boolean  :is_repeatable, null: false, default: false
      t.text     :xml_translation
      t.integer  :sort_order,    null: false

      t.references :parent, polymorphic: true, index: true
      t.belongs_to :created_by, index: false
      t.belongs_to :updated_by, index: false

      t.timestamps
    end

    add_index :dynamic_field_groups, :string_key, unique: true
    add_index :dynamic_field_groups, [:string_key, :parent_type, :parent_id], unique: true, name: 'index_dynamic_field_groups_on_string_key_and_parent'
  end
end
