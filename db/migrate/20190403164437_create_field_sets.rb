class CreateFieldSets < ActiveRecord::Migration[5.2]
  def change
    create_table :field_sets do |t|
      t.string :display_label, null: false

      t.belongs_to :project

      t.timestamps
    end

    create_join_table :enabled_dynamic_fields, :field_sets do |t|
      t.index :field_set_id
    end
  end
end
