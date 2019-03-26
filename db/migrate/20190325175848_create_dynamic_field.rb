class CreateDynamicField < ActiveRecord::Migration[5.2]
  def change
    create_table :dynamic_fields do |t|
      t.string  :string_key,    null: false
      t.string  :display_label, null: false
      t.string  :field_type,    null: false, default: 'string'
      t.integer :sort_order,    null: false

      t.boolean :is_facetable,  null: false, default: false
      t.string  :filter_label
      t.string  :controlled_vocabulary
      t.text    :select_options
      t.text    :additional_data_json

      t.boolean :is_keyword_searchable,    null: false, default: false
      t.boolean :is_title_searchable,      null: false, default: false
      t.boolean :is_identifier_searchable, null: false, default: false

      t.belongs_to :dynamic_field_group

      t.belongs_to :created_by, index: false
      t.belongs_to :updated_by, index: false

      t.timestamps
    end

    add_index :dynamic_fields, :controlled_vocabulary
    add_index :dynamic_fields, [:string_key, :dynamic_field_group_id], unique: true
    add_index :dynamic_fields, :string_key
  end
end
