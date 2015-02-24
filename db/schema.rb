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

ActiveRecord::Schema.define(version: 20141104010523) do

  create_table "authorized_terms", force: :cascade do |t|
    t.string   "pid",                             limit: 255
    t.text     "value",                           limit: 65535, null: false
    t.text     "code",                            limit: 65535
    t.text     "value_uri",                       limit: 65535
    t.string   "unique_value_and_value_uri_hash", limit: 64
    t.text     "authority",                       limit: 65535
    t.text     "authority_uri",                   limit: 65535
    t.integer  "controlled_vocabulary_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorized_terms", ["controlled_vocabulary_id"], name: "index_authorized_terms_on_controlled_vocabulary_id", using: :btree
  add_index "authorized_terms", ["unique_value_and_value_uri_hash"], name: "index_authorized_terms_on_unique_value_and_value_uri_hash", using: :btree

  create_table "controlled_vocabularies", force: :cascade do |t|
    t.string   "pid",                    limit: 255
    t.string   "string_key",             limit: 255
    t.string   "display_label",          limit: 255
    t.integer  "pid_generator_id",       limit: 4
    t.boolean  "only_managed_by_admins", limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controlled_vocabularies", ["only_managed_by_admins"], name: "index_controlled_vocabularies_on_only_managed_by_admins", using: :btree
  add_index "controlled_vocabularies", ["pid_generator_id"], name: "index_controlled_vocabularies_on_pid_generator_id", using: :btree

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
    t.boolean  "is_repeatable",                   limit: 1,     default: false, null: false
    t.integer  "xml_datastream_id",               limit: 4
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
  add_index "dynamic_field_groups", ["xml_datastream_id"], name: "index_dynamic_field_groups_on_xml_datastream_id", using: :btree

  create_table "dynamic_fields", force: :cascade do |t|
    t.string   "string_key",                     limit: 255,                      null: false
    t.string   "display_label",                  limit: 255,                      null: false
    t.integer  "parent_dynamic_field_group_id",  limit: 4
    t.integer  "sort_order",                     limit: 4,                        null: false
    t.string   "dynamic_field_type",             limit: 255,   default: "string", null: false
    t.integer  "controlled_vocabulary_id",       limit: 4
    t.text     "additional_data_json",           limit: 65535
    t.boolean  "is_keyword_searchable",          limit: 1,     default: false,    null: false
    t.boolean  "is_facet_field",                 limit: 1,     default: false,    null: false
    t.boolean  "required_for_group_save",        limit: 1,     default: false,    null: false
    t.string   "standalone_field_label",         limit: 255,   default: "",       null: false
    t.boolean  "is_searchable_identifier_field", limit: 1,     default: false,    null: false
    t.boolean  "is_searchable_title_field",      limit: 1,     default: false,    null: false
    t.boolean  "is_single_field_searchable",     limit: 1,     default: false,    null: false
    t.integer  "created_by_id",                  limit: 4
    t.integer  "updated_by_id",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dynamic_fields", ["controlled_vocabulary_id"], name: "index_dynamic_fields_on_controlled_vocabulary_id", using: :btree
  add_index "dynamic_fields", ["parent_dynamic_field_group_id"], name: "index_dynamic_fields_on_parent_dynamic_field_group_id", using: :btree
  add_index "dynamic_fields", ["string_key", "parent_dynamic_field_group_id"], name: "unique_string_key_and_parent_dynamic_field_group", unique: true, using: :btree
  add_index "dynamic_fields", ["string_key"], name: "index_dynamic_fields_on_string_key", using: :btree

  create_table "enabled_dynamic_fields", force: :cascade do |t|
    t.integer  "project_id",                               limit: 4,                     null: false
    t.integer  "dynamic_field_id",                         limit: 4,                     null: false
    t.integer  "digital_object_type_id",                   limit: 4,                     null: false
    t.boolean  "required",                                 limit: 1,     default: false, null: false
    t.boolean  "locked",                                   limit: 1,     default: false, null: false
    t.boolean  "hidden",                                   limit: 1,     default: false, null: false
    t.boolean  "only_save_dynamic_field_group_if_present", limit: 1,     default: false, null: false
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

  create_table "fieldsets", force: :cascade do |t|
    t.string   "display_label", limit: 255
    t.integer  "project_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fieldsets", ["project_id"], name: "index_fieldsets_on_project_id", using: :btree

  create_table "pid_generators", force: :cascade do |t|
    t.string   "namespace",  limit: 255
    t.string   "template",   limit: 255
    t.string   "seed",       limit: 255
    t.integer  "sequence",   limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_permissions", force: :cascade do |t|
    t.integer  "project_id",       limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "can_create",       limit: 1, default: false, null: false
    t.boolean  "can_read",         limit: 1, default: false, null: false
    t.boolean  "can_update",       limit: 1, default: false, null: false
    t.boolean  "can_delete",       limit: 1, default: false, null: false
    t.boolean  "is_project_admin", limit: 1, default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  add_index "projects", ["pid_generator_id"], name: "index_projects_on_pid_generator_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "is_admin",               limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
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

end
