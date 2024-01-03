class CreateEnabledDynamicFieldsFieldsets < ActiveRecord::Migration[4.2]
  def change
    create_table :enabled_dynamic_fields_fieldsets, id: false do |t|
      t.references :enabled_dynamic_field
      t.references :fieldset
    end

    add_index "enabled_dynamic_fields_fieldsets", ["enabled_dynamic_field_id"], name: "enabled_dynamic_field_id"
    add_index "enabled_dynamic_fields_fieldsets", ["fieldset_id"], name: "fieldset_id"
    add_index "enabled_dynamic_fields_fieldsets", ["enabled_dynamic_field_id", "fieldset_id"], name: "unique_enabled_dynamic_field_id_and_fieldset_id", unique: true

  end
end
