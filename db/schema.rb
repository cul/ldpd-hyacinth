# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_04_06_150728) do

  create_table "archived_assignments", force: :cascade do |t|
    t.integer "original_assignment_id", null: false
    t.string "digital_object_pid", null: false
    t.integer "project_id", null: false
    t.integer "task", null: false
    t.text "summary"
    t.text "original", limit: 16777215
    t.text "proposed", limit: 16777215
    t.index ["digital_object_pid"], name: "index_archived_assignments_on_digital_object_pid"
    t.index ["project_id"], name: "index_archived_assignments_on_project_id"
    t.index ["task"], name: "index_archived_assignments_on_task"
  end

  create_table "assignments", force: :cascade do |t|
    t.string "digital_object_pid", null: false
    t.integer "project_id", null: false
    t.integer "assigner_id", null: false
    t.integer "assignee_id", null: false
    t.integer "status"
    t.integer "task", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "original", limit: 16777215
    t.text "proposed", limit: 16777215
    t.text "note"
    t.index ["assignee_id"], name: "index_assignments_on_assignee_id"
    t.index ["assigner_id"], name: "index_assignments_on_assigner_id"
    t.index ["digital_object_pid", "task"], name: "index_assignments_on_digital_object_pid_and_task", unique: true
    t.index ["project_id"], name: "index_assignments_on_project_id"
  end

  create_table "controlled_vocabularies", force: :cascade do |t|
    t.string "string_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "require_controlled_vocabulary_manager_permission", default: false, null: false
    t.boolean "prohibit_temp_terms", default: false, null: false
    t.index ["require_controlled_vocabulary_manager_permission"], name: "idx_controlled_vocabularies_require_manager_permission"
  end

  create_table "csv_exports", force: :cascade do |t|
    t.text "search_params"
    t.integer "user_id"
    t.text "path_to_csv_file"
    t.text "export_errors"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration", default: 0, null: false
    t.integer "number_of_records_processed", default: 0, null: false
    t.index ["status"], name: "index_csv_exports_on_status"
    t.index ["user_id"], name: "index_csv_exports_on_user_id"
  end

  create_table "digital_object_imports", force: :cascade do |t|
    t.text "digital_object_data"
    t.integer "status", default: 0, null: false
    t.text "digital_object_errors"
    t.integer "import_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requeue_count", default: 0, null: false
    t.integer "csv_row_number"
    t.text "prerequisite_csv_row_numbers"
    t.index ["csv_row_number"], name: "index_digital_object_imports_on_csv_row_number"
    t.index ["import_job_id"], name: "index_digital_object_imports_on_import_job_id"
    t.index ["status"], name: "index_digital_object_imports_on_status"
  end

  create_table "digital_object_records", force: :cascade do |t|
    t.string "pid"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "first_published_at"
    t.string "uuid"
    t.boolean "perform_derivative_processing", default: false, null: false
    t.string "digital_object_data_location_uri", limit: 1000
    t.index ["perform_derivative_processing"], name: "index_digital_object_records_on_perform_derivative_processing"
    t.index ["pid"], name: "index_digital_object_records_on_pid", unique: true
    t.index ["uuid"], name: "index_digital_object_records_on_uuid", unique: true
  end

  create_table "digital_object_types", force: :cascade do |t|
    t.string "string_key"
    t.string "display_label"
    t.integer "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort_order"], name: "index_digital_object_types_on_sort_order"
  end

  create_table "dynamic_field_group_categories", force: :cascade do |t|
    t.string "display_label"
    t.integer "sort_order", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["display_label"], name: "index_dynamic_field_group_categories_on_display_label"
  end

  create_table "dynamic_field_groups", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.integer "parent_dynamic_field_group_id"
    t.integer "sort_order", null: false
    t.boolean "is_repeatable", default: false, null: false
    t.text "xml_translation"
    t.integer "dynamic_field_group_category_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["dynamic_field_group_category_id"], name: "index_dynamic_field_groups_on_dynamic_field_group_category_id"
    t.index ["parent_dynamic_field_group_id"], name: "index_dynamic_field_groups_on_parent_dynamic_field_group_id"
    t.index ["string_key", "parent_dynamic_field_group_id"], name: "unique_string_key_for_same_parent_dynamic_field_group", unique: true
    t.index ["string_key"], name: "index_dynamic_field_groups_on_string_key"
  end

  create_table "dynamic_fields", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.integer "parent_dynamic_field_group_id"
    t.integer "sort_order", null: false
    t.string "dynamic_field_type", default: "string", null: false
    t.text "additional_data_json"
    t.boolean "is_keyword_searchable", default: false, null: false
    t.boolean "is_facet_field", default: false, null: false
    t.boolean "required_for_group_save", default: false, null: false
    t.string "standalone_field_label", default: "", null: false
    t.boolean "is_searchable_identifier_field", default: false, null: false
    t.boolean "is_searchable_title_field", default: false, null: false
    t.boolean "is_single_field_searchable", default: false, null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "controlled_vocabulary_string_key"
    t.index ["controlled_vocabulary_string_key"], name: "index_dynamic_fields_on_controlled_vocabulary_string_key"
    t.index ["parent_dynamic_field_group_id"], name: "index_dynamic_fields_on_parent_dynamic_field_group_id"
    t.index ["string_key", "parent_dynamic_field_group_id"], name: "unique_string_key_and_parent_dynamic_field_group", unique: true
    t.index ["string_key"], name: "index_dynamic_fields_on_string_key"
  end

  create_table "enabled_dynamic_fields", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "dynamic_field_id", null: false
    t.integer "digital_object_type_id", null: false
    t.boolean "required", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.boolean "only_save_dynamic_field_group_if_present", default: false, null: false
    t.text "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_object_type_id"], name: "index_enabled_dynamic_fields_on_digital_object_type_id"
    t.index ["dynamic_field_id"], name: "index_enabled_dynamic_fields_on_dynamic_field_id"
    t.index ["project_id"], name: "index_enabled_dynamic_fields_on_project_id"
  end

  create_table "enabled_dynamic_fields_fieldsets", id: false, force: :cascade do |t|
    t.integer "enabled_dynamic_field_id"
    t.integer "fieldset_id"
    t.index ["enabled_dynamic_field_id", "fieldset_id"], name: "unique_enabled_dynamic_field_id_and_fieldset_id", unique: true
    t.index ["enabled_dynamic_field_id"], name: "enabled_dynamic_field_id"
    t.index ["fieldset_id"], name: "fieldset_id"
  end

  create_table "enabled_publish_targets", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "publish_target_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_enabled_publish_targets_on_project_id"
    t.index ["publish_target_id"], name: "index_enabled_publish_targets_on_publish_target_id"
  end

  create_table "fieldsets", force: :cascade do |t|
    t.string "display_label"
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_fieldsets_on_project_id"
  end

  create_table "import_jobs", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "path_to_csv_file"
    t.integer "priority", default: 0, null: false
    t.index ["priority"], name: "index_import_jobs_on_priority"
    t.index ["user_id"], name: "index_import_jobs_on_user_id"
  end

  create_table "pid_generators", force: :cascade do |t|
    t.string "namespace"
    t.string "template"
    t.string "seed"
    t.integer "sequence", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["namespace"], name: "index_pid_generators_on_namespace", unique: true
  end

  create_table "project_permissions", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "can_create", default: false, null: false
    t.boolean "can_read", default: false, null: false
    t.boolean "can_update", default: false, null: false
    t.boolean "can_delete", default: false, null: false
    t.boolean "is_project_admin", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "can_publish", default: false, null: false
    t.index ["project_id"], name: "index_project_permissions_on_project_id"
    t.index ["user_id"], name: "index_project_permissions_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "pid"
    t.integer "pid_generator_id"
    t.string "display_label"
    t.string "string_key"
    t.text "full_path_to_custom_asset_directory"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "uri"
    t.string "short_label", limit: 255
    t.text "enabled_publish_target_pids"
    t.string "primary_publish_target_pid"
    t.string "default_storage_type", default: "file", null: false
    t.index ["display_label"], name: "index_projects_on_display_label", unique: true
    t.index ["pid"], name: "index_projects_on_pid", unique: true
    t.index ["pid_generator_id"], name: "index_projects_on_pid_generator_id"
    t.index ["string_key"], name: "index_projects_on_string_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.boolean "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "can_manage_all_controlled_vocabularies", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "xml_datastreams", force: :cascade do |t|
    t.string "string_key", limit: 64
    t.string "display_label"
    t.text "xml_translation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "csv_exports", "users"
end
