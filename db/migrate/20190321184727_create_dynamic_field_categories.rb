class CreateDynamicFieldCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :dynamic_field_categories do |t|
      t.string :display_label, null: false
      t.integer :sort_order, null: false

      t.timestamps

      t.index :display_label, unique: true
    end
  end
end
