class CreateDynamicFieldGroupCategories < ActiveRecord::Migration
  def change
    create_table :dynamic_field_group_categories do |t|
      t.string :display_label, index: true
      t.integer :sort_order, null: false

      t.timestamps
    end
  end
end
