class CreateParentChildRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :parent_child_relationships do |t|
      t.references :parent, null: false
      t.references :child, null: false
      t.integer :sort_order, null: false, index: true
    end

    # Need to declare foreign keys manually, otherwise Rails runs into an issue
    add_foreign_key :parent_child_relationships, :digital_objects, column: 'parent_id'
    add_foreign_key :parent_child_relationships, :digital_objects, column: 'child_id'
    add_index :parent_child_relationships, [:parent_id, :child_id, :sort_order], unique: true, name: 'unique_parent_and_child_and_sort_order'
  end
end
