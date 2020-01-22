class CreateEnabledDynamicFields < ActiveRecord::Migration[6.0]
  def change
    create_table :enabled_dynamic_fields do |t|
      t.belongs_to :project,                           null: false
      t.belongs_to :dynamic_field,                     null: false

      t.string   :digital_object_type,                 null: false
      t.boolean  :required,            default: false, null: false
      t.boolean  :locked,              default: false, null: false
      t.boolean  :hidden,              default: false, null: false
      t.boolean  :owner_only,          default: false, null: false
      t.text     :default_value

      t.timestamps
    end

    add_index :enabled_dynamic_fields, [:digital_object_type, :project_id], name: 'index_enabled_dynamic_fields_on_project_and_type'
    add_index :enabled_dynamic_fields, [:digital_object_type, :project_id, :dynamic_field_id], name: 'index_enabled_dynamic_fields_unique', unique: true
  end
end
