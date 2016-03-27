# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160325101222) do

  create_table "controlled_vocabularies", force: :cascade do |t|
    t.string   "string_key",                                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "require_controlled_vocabulary_manager_permission",             default: false, null: false
  end

  create_table "csv_exports", force: :cascade do |t|
    t.text     "search_params",               limit: 65535
    t.integer  "user_id",                     limit: 4
    t.text     "path_to_csv_file",            limit: 65535
    t.text     "export_errors",               limit: 65535
    t.integer  "status",                      limit: 4,     default: 0, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "duration",                    limit: 4,     default: 0, null: false
    t.integer  "number_of_records_processed", limit: 4,     default: 0, null: false
  end

  add_index "csv_exports", ["status"], name: "index_csv_exports_on_status", using: :btree
  add_index "csv_exports", ["user_id"], name: "index_csv_exports_on_user_id", using: :btree

  create_table "digital_object_imports", force: :cascade do |t|
    t.text     "digital_object_data",   limit: 65535
    t.integer  "status",                limit: 4,     default: 0, null: false
    t.text     "digital_object_errors", limit: 65535
    t.integer  "import_job_id",         limit: 4,                 null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "requeue_count",         limit: 4,     default: 0, null: false
    t.integer  "csv_row_number",        limit: 4
  end

  add_index "digital_object_imports", ["import_job_id"], name: "index_digital_object_imports_on_import_job_id", using: :btree
  add_index "digital_object_imports", ["status"], name: "index_digital_object_imports_on_status", using: :btree

  create_table "digital_object_records", force: :cascade do |t|
    t.string   "pid",           limit: 255
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "digital_object_records", ["pid"], name: "index_digital_object_records_on_pid", unique: true, using: :btree

  create_table "digital_object_types", force: :cascade do |t|
    t.string   "string_key",    limit: 255
    t.string   "display_label", limit: 255
    t.integer  "sort_order",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "digital_object_types", ["sort_order"], name: "index_digital_object_types_on_sort_order", using: :btree

  create_table "dynamic_field_group_categories", force: :cascade do |t|
    t.string   "display_label", limit: 255
    t.integer  "sort_order",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dynamic_field_group_categories", ["display_label"], name: "index_dynamic_field_group_categories_on_display_label", using: :btree

  create_table "dynamic_field_groups", force: :cascade do |t|
    t.string   "string_key",                      limit: 255,                   null: false
    t.string   "display_label",                   limit: 255,                   null: false
    t.integer  "parent_dynamic_field_group_id",   limit: 4
    t.integer  "sort_order",                      limit: 4,                     null: false
    t.boolean  "is_repeatable",                                 default: false, null: false
    t.text     "xml_translation",                 limit: 65535
    t.integer  "dynamic_field_group_category_id", limit: 4
    t.integer  "created_by_id",                   limit: 4
    t.integer  "updated_by_id",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dynamic_field_groups", ["dynamic_field_group_category_id"], name: "index_dynamic_field_groups_on_dynamic_field_group_category_id", using: :btree
  add_index "dynamic_field_groups", ["parent_dynamic_field_group_id"], name: "index_dynamic_field_groups_on_parent_dynamic_field_group_id", using: :btree
  add_index "dynamic_field_groups", ["string_key", "parent_dynamic_field_group_id"], name: "unique_string_key_for_same_parent_dynamic_field_group", unique: true, using: :btree
  add_index "dynamic_field_groups", ["string_key"], name: "index_dynamic_field_groups_on_string_key", using: :btree

  create_table "dynamic_fields", force: :cascade do |t|
    t.string   "string_key",                       limit: 255,                      null: false
    t.string   "display_label",                    limit: 255,                      null: false
    t.integer  "parent_dynamic_field_group_id",    limit: 4
    t.integer  "sort_order",                       limit: 4,                        null: false
    t.string   "dynamic_field_type",               limit: 255,   default: "string", null: false
    t.text     "additional_data_json",             limit: 65535
    t.boolean  "is_keyword_searchable",                          default: false,    null: false
    t.boolean  "is_facet_field",                                 default: false,    null: false
    t.boolean  "required_for_group_save",                        default: false,    null: false
    t.string   "standalone_field_label",           limit: 255,   default: "",       null: false
    t.boolean  "is_searchable_identifier_field",                 default: false,    null: false
    t.boolean  "is_searchable_title_field",                      default: false,    null: false
    t.boolean  "is_single_field_searchable",                     default: false,    null: false
    t.integer  "created_by_id",                    limit: 4
    t.integer  "updated_by_id",                    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "controlled_vocabulary_string_key", limit: 255
  end

  add_index "dynamic_fields", ["controlled_vocabulary_string_key"], name: "index_dynamic_fields_on_controlled_vocabulary_string_key", using: :btree
  add_index "dynamic_fields", ["parent_dynamic_field_group_id"], name: "index_dynamic_fields_on_parent_dynamic_field_group_id", using: :btree
  add_index "dynamic_fields", ["string_key", "parent_dynamic_field_group_id"], name: "unique_string_key_and_parent_dynamic_field_group", unique: true, using: :btree
  add_index "dynamic_fields", ["string_key"], name: "index_dynamic_fields_on_string_key", using: :btree

  create_table "enabled_dynamic_fields", force: :cascade do |t|
    t.integer  "project_id",                               limit: 4,                     null: false
    t.integer  "dynamic_field_id",                         limit: 4,                     null: false
    t.integer  "digital_object_type_id",                   limit: 4,                     null: false
    t.boolean  "required",                                               default: false, null: false
    t.boolean  "locked",                                                 default: false, null: false
    t.boolean  "hidden",                                                 default: false, null: false
    t.boolean  "only_save_dynamic_field_group_if_present",               default: false, null: false
    t.text     "default_value",                            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enabled_dynamic_fields", ["digital_object_type_id"], name: "index_enabled_dynamic_fields_on_digital_object_type_id", using: :btree
  add_index "enabled_dynamic_fields", ["dynamic_field_id"], name: "index_enabled_dynamic_fields_on_dynamic_field_id", using: :btree
  add_index "enabled_dynamic_fields", ["project_id"], name: "index_enabled_dynamic_fields_on_project_id", using: :btree

  create_table "enabled_dynamic_fields_fieldsets", id: false, force: :cascade do |t|
    t.integer "enabled_dynamic_field_id", limit: 4
    t.integer "fieldset_id",              limit: 4
  end

  add_index "enabled_dynamic_fields_fieldsets", ["enabled_dynamic_field_id", "fieldset_id"], name: "unique_enabled_dynamic_field_id_and_fieldset_id", unique: true, using: :btree
  add_index "enabled_dynamic_fields_fieldsets", ["enabled_dynamic_field_id"], name: "enabled_dynamic_field_id", using: :btree
  add_index "enabled_dynamic_fields_fieldsets", ["fieldset_id"], name: "fieldset_id", using: :btree

  create_table "enabled_publish_targets", force: :cascade do |t|
    t.integer  "project_id",        limit: 4, null: false
    t.integer  "publish_target_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enabled_publish_targets", ["project_id"], name: "index_enabled_publish_targets_on_project_id", using: :btree
  add_index "enabled_publish_targets", ["publish_target_id"], name: "index_enabled_publish_targets_on_publish_target_id", using: :btree

  create_table "fieldsets", force: :cascade do |t|
    t.string   "display_label", limit: 255
    t.integer  "project_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fieldsets", ["project_id"], name: "index_fieldsets_on_project_id", using: :btree

  create_table "import_jobs", force: :cascade do |t|
    t.string   "name",             limit: 255,   null: false
    t.integer  "user_id",          limit: 4,     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "path_to_csv_file", limit: 65535
  end

  add_index "import_jobs", ["user_id"], name: "index_import_jobs_on_user_id", using: :btree

  create_table "pid_generators", force: :cascade do |t|
    t.string   "namespace",  limit: 255
    t.string   "template",   limit: 255
    t.string   "seed",       limit: 255
    t.integer  "sequence",   limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pid_generators", ["namespace"], name: "index_pid_generators_on_namespace", unique: true, using: :btree

  create_table "project_permissions", force: :cascade do |t|
    t.integer  "project_id",       limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "can_create",                 default: false, null: false
    t.boolean  "can_read",                   default: false, null: false
    t.boolean  "can_update",                 default: false, null: false
    t.boolean  "can_delete",                 default: false, null: false
    t.boolean  "is_project_admin",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_publish",                default: false, null: false
  end

  add_index "project_permissions", ["project_id"], name: "index_project_permissions_on_project_id", using: :btree
  add_index "project_permissions", ["user_id"], name: "index_project_permissions_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "pid",                                 limit: 255
    t.integer  "pid_generator_id",                    limit: 4
    t.string   "display_label",                       limit: 255
    t.string   "string_key",                          limit: 255
    t.text     "full_path_to_custom_asset_directory", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "uri",                                 limit: 65535
  end

  add_index "projects", ["display_label"], name: "index_projects_on_display_label", unique: true, using: :btree
  add_index "projects", ["pid"], name: "index_projects_on_pid", unique: true, using: :btree
  add_index "projects", ["pid_generator_id"], name: "index_projects_on_pid_generator_id", using: :btree
  add_index "projects", ["string_key"], name: "index_projects_on_string_key", unique: true, using: :btree

  create_table "publish_targets", force: :cascade do |t|
    t.string "pid",                    limit: 255
    t.string "display_label",          limit: 255
    t.string "publish_url",            limit: 2000
    t.string "encrypted_api_key",      limit: 255
    t.string "encrypted_api_key_salt", limit: 255
    t.string "encrypted_api_key_iv",   limit: 255
    t.string "string_key",             limit: 255
  end

  add_index "publish_targets", ["pid"], name: "index_publish_targets_on_pid", unique: true, using: :btree
  add_index "publish_targets", ["string_key"], name: "index_publish_targets_on_string_key", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                             limit: 255
    t.string   "last_name",                              limit: 255
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",                     limit: 255, default: "",    null: false
    t.string   "reset_password_token",                   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                     limit: 255
    t.string   "last_sign_in_ip",                        limit: 255
    t.boolean  "can_manage_all_controlled_vocabularies",             default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "xml_datastreams", force: :cascade do |t|
    t.string   "string_key",      limit: 64
    t.string   "display_label",   limit: 255
    t.text     "xml_translation", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "csv_exports", "users"
end
