class CreateEnabledDynamicFields < ActiveRecord::Migration[4.2]
  def change
    create_table :enabled_dynamic_fields do |t|
      t.references :project, null: false, index: true
      t.references :dynamic_field, null: false, index: true
      t.references :digital_object_type, null: false, index: true
      t.boolean :required, null: false, default: false
      t.boolean :locked, null: false, default: false
      t.boolean :hidden, null: false, default: false
      t.boolean :only_save_dynamic_field_group_if_present, null:false, default: false # TODO: Do we actually need this feature?
      t.text :default_value

      t.timestamps
    end

  end
end
