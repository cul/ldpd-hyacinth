class CreateFieldExportRules < ActiveRecord::Migration[6.0]
  def change
    create_table :field_export_profiles do |t|
      t.string :name,      null: false
      t.text :translation_logic, null: false
      t.timestamps
    end

    create_table :export_rules do |t|
      t.belongs_to :dynamic_field_group
      t.belongs_to :field_export_profile

      t.text :translation_logic, null: false
      t.timestamps
    end
  end
end
