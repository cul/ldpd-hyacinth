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

ActiveRecord::Schema[7.0].define(version: 2021_08_19_192227) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "batch_exports", force: :cascade do |t|
    t.text "search_params"
    t.integer "user_id"
    t.text "file_location"
    t.text "export_errors"
    t.integer "status", default: 0, null: false
    t.integer "duration", default: 0, null: false
    t.integer "number_of_records_processed", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_records_to_process", default: 0, null: false
    t.text "export_filter_config"
    t.index ["status"], name: "index_batch_exports_on_status"
    t.index ["user_id"], name: "index_batch_exports_on_user_id"
  end

  create_table "batch_imports", force: :cascade do |t|
    t.integer "user_id"
    t.text "file_location"
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cancelled", default: false, null: false
    t.string "original_filename"
    t.text "setup_errors"
    t.index ["user_id"], name: "index_batch_imports_on_user_id"
  end

  create_table "database_entry_locks", force: :cascade do |t|
    t.string "lock_key", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.index ["lock_key"], name: "index_database_entry_locks_on_lock_key", unique: true
  end

  create_table "digital_object_imports", force: :cascade do |t|
    t.integer "batch_import_id"
    t.text "digital_object_data", null: false
    t.text "import_errors"
    t.integer "status", default: 0, null: false
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_import_id", "index"], name: "index_digital_object_imports_on_batch_import_id_and_index", unique: true
    t.index ["batch_import_id", "status"], name: "index_digital_object_imports_on_batch_import_id_and_status"
    t.index ["batch_import_id"], name: "index_digital_object_imports_on_batch_import_id"
    t.index ["index"], name: "index_digital_object_imports_on_index"
    t.index ["status"], name: "index_digital_object_imports_on_status"
  end

  create_table "digital_objects", force: :cascade do |t|
    t.string "uid", null: false
    t.string "metadata_location_uri"
    t.string "optimistic_lock_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "", null: false
    t.datetime "first_published_at", precision: nil
    t.datetime "preserved_at", precision: nil
    t.datetime "first_preserved_at", precision: nil
    t.integer "state", default: 0, null: false
    t.string "doi"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "backup_metadata_location_uri"
    t.index ["created_by_id"], name: "index_digital_objects_on_created_by_id"
    t.index ["uid"], name: "index_digital_objects_on_uid", unique: true
    t.index ["updated_by_id"], name: "index_digital_objects_on_updated_by_id"
  end

  create_table "dynamic_field_categories", force: :cascade do |t|
    t.string "display_label", null: false
    t.integer "sort_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "metadata_form", default: 0, null: false
    t.index ["display_label"], name: "index_dynamic_field_categories_on_display_label", unique: true
  end

  create_table "dynamic_field_groups", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.boolean "is_repeatable", default: false, null: false
    t.text "xml_translation"
    t.integer "sort_order", null: false
    t.string "parent_type"
    t.integer "parent_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path"
    t.index ["parent_type", "parent_id"], name: "index_dynamic_field_groups_on_parent_type_and_parent_id"
    t.index ["path"], name: "index_dynamic_field_groups_on_path", unique: true
    t.index ["string_key", "parent_type", "parent_id"], name: "index_dynamic_field_groups_on_string_key_and_parent", unique: true
    t.index ["string_key"], name: "index_dynamic_field_groups_on_string_key"
  end

  create_table "dynamic_fields", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.string "field_type", default: "string", null: false
    t.integer "sort_order", null: false
    t.boolean "is_facetable", default: false, null: false
    t.string "filter_label"
    t.string "controlled_vocabulary"
    t.text "select_options"
    t.text "additional_data_json"
    t.boolean "is_keyword_searchable", default: false, null: false
    t.boolean "is_title_searchable", default: false, null: false
    t.boolean "is_identifier_searchable", default: false, null: false
    t.integer "dynamic_field_group_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path"
    t.index ["controlled_vocabulary"], name: "index_dynamic_fields_on_controlled_vocabulary"
    t.index ["dynamic_field_group_id"], name: "index_dynamic_fields_on_dynamic_field_group_id"
    t.index ["path"], name: "index_dynamic_fields_on_path", unique: true
    t.index ["string_key", "dynamic_field_group_id"], name: "index_dynamic_fields_on_string_key_and_dynamic_field_group_id", unique: true
    t.index ["string_key"], name: "index_dynamic_fields_on_string_key"
  end

  create_table "enabled_dynamic_fields", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "dynamic_field_id", null: false
    t.string "digital_object_type", null: false
    t.boolean "required", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.boolean "owner_only", default: false, null: false
    t.text "default_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "shareable", default: false, null: false
    t.index ["digital_object_type", "project_id", "dynamic_field_id"], name: "index_enabled_dynamic_fields_unique", unique: true
    t.index ["digital_object_type", "project_id"], name: "index_enabled_dynamic_fields_on_project_and_type"
    t.index ["dynamic_field_id"], name: "index_enabled_dynamic_fields_on_dynamic_field_id"
    t.index ["project_id"], name: "index_enabled_dynamic_fields_on_project_id"
  end

  create_table "enabled_dynamic_fields_field_sets", id: false, force: :cascade do |t|
    t.integer "enabled_dynamic_field_id", null: false
    t.integer "field_set_id", null: false
    t.index ["field_set_id"], name: "index_enabled_dynamic_fields_field_sets_on_field_set_id"
  end

  create_table "export_rules", force: :cascade do |t|
    t.integer "dynamic_field_group_id"
    t.integer "field_export_profile_id"
    t.text "translation_logic", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dynamic_field_group_id"], name: "index_export_rules_on_dynamic_field_group_id"
    t.index ["field_export_profile_id", "dynamic_field_group_id"], name: "index_export_rules_on_export_profile_and_dynamic_field_group", unique: true
    t.index ["field_export_profile_id"], name: "index_export_rules_on_field_export_profile_id"
  end

  create_table "field_export_profiles", force: :cascade do |t|
    t.string "name", null: false
    t.text "translation_logic", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_sets", force: :cascade do |t|
    t.string "display_label", null: false
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_field_sets_on_project_id"
  end

  create_table "import_prerequisites", force: :cascade do |t|
    t.integer "digital_object_import_id"
    t.integer "prerequisite_digital_object_import_id"
    t.integer "batch_import_id"
    t.datetime "created_at", precision: nil, null: false
    t.index ["batch_import_id", "digital_object_import_id", "prerequisite_digital_object_import_id"], name: "unique_import_prerequisite", unique: true
    t.index ["batch_import_id"], name: "index_import_prerequisites_on_batch_import_id"
    t.index ["digital_object_import_id"], name: "index_import_prerequisites_on_digital_object_import_id"
    t.index ["prerequisite_digital_object_import_id"], name: "prerequisite_digital_object_import_id"
  end

  create_table "language_subtags", force: :cascade do |t|
    t.string "subtag", null: false
    t.string "subtag_type", null: false
    t.datetime "added", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope"
    t.datetime "deprecated", precision: nil
    t.integer "preferred_value_id"
    t.integer "suppress_script_id"
    t.integer "macrolanguage_id"
    t.text "prefixes"
    t.text "comments"
    t.text "descriptions"
    t.index ["preferred_value_id"], name: "index_language_subtags_on_preferred_value_id"
    t.index ["subtag", "subtag_type"], name: "index_language_subtags_on_subtag_and_subtag_type", unique: true
    t.index ["subtag_type"], name: "index_language_subtags_on_subtag_type"
  end

  create_table "language_subtags_tags", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "subtag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subtag_id"], name: "index_language_subtags_tags_on_subtag_id"
    t.index ["tag_id", "subtag_id"], name: "tag_subtag", unique: true
    t.index ["tag_id"], name: "index_language_subtags_tags_on_tag_id"
  end

  create_table "language_tags", force: :cascade do |t|
    t.string "tag", null: false
    t.string "tag_type", default: "redundant", null: false
    t.datetime "added", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deprecated", precision: nil
    t.integer "preferred_value_id"
    t.text "comments"
    t.text "descriptions"
    t.index ["preferred_value_id"], name: "index_language_tags_on_preferred_value_id"
    t.index ["tag"], name: "index_language_tags_on_tag", unique: true
    t.index ["tag_type"], name: "index_language_tags_on_tag_type"
  end

  create_table "parent_child_relationships", force: :cascade do |t|
    t.integer "parent_id", null: false
    t.integer "child_id", null: false
    t.integer "sort_order", null: false
    t.index ["child_id"], name: "index_parent_child_relationships_on_child_id"
    t.index ["parent_id", "child_id", "sort_order"], name: "unique_parent_and_child_and_sort_order", unique: true
    t.index ["parent_id"], name: "index_parent_child_relationships_on_parent_id"
    t.index ["sort_order"], name: "index_parent_child_relationships_on_sort_order"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "user_id"
    t.string "action", null: false
    t.string "subject"
    t.string "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "pid_generators", force: :cascade do |t|
    t.string "namespace"
    t.string "template"
    t.string "seed"
    t.integer "sequence", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace"], name: "index_pid_generators_on_namespace", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_url"
    t.boolean "has_asset_rights", default: false, null: false
    t.index ["display_label"], name: "index_projects_on_display_label", unique: true
    t.index ["string_key"], name: "index_projects_on_string_key", unique: true
  end

  create_table "projects_publish_targets", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "publish_target_id", null: false
    t.index ["project_id", "publish_target_id"], name: "unique_project_and_publish_target", unique: true
    t.index ["project_id"], name: "index_projects_publish_targets_on_project_id"
    t.index ["publish_target_id"], name: "index_projects_publish_targets_on_publish_target_id"
  end

  create_table "publish_entries", force: :cascade do |t|
    t.integer "digital_object_id", null: false
    t.integer "publish_target_id", null: false
    t.integer "published_by_id"
    t.datetime "published_at", precision: nil
    t.text "citation_location"
    t.index ["digital_object_id", "publish_target_id"], name: "unique_digital_object_and_publish_target", unique: true
    t.index ["digital_object_id"], name: "index_publish_entries_on_digital_object_id"
    t.index ["publish_target_id"], name: "index_publish_entries_on_publish_target_id"
    t.index ["published_by_id"], name: "index_publish_entries_on_published_by_id"
  end

  create_table "publish_targets", force: :cascade do |t|
    t.text "publish_url", null: false
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_allowed_doi_target", default: false, null: false
    t.integer "doi_priority", default: 100, null: false
    t.string "string_key"
    t.index ["string_key"], name: "index_publish_targets_on_string_key", unique: true
  end

  create_table "resource_requests", force: :cascade do |t|
    t.string "digital_object_uid", null: false
    t.integer "job_type", null: false
    t.integer "status", default: 0, null: false
    t.text "src_file_location", null: false
    t.text "options"
    t.text "processing_errors"
    t.index ["digital_object_uid"], name: "index_resource_requests_on_digital_object_uid"
    t.index ["job_type"], name: "index_resource_requests_on_job_type"
    t.index ["status"], name: "index_resource_requests_on_status"
  end

  create_table "terms", force: :cascade do |t|
    t.integer "vocabulary_id", null: false
    t.string "pref_label", null: false
    t.text "alt_labels"
    t.string "uri", null: false
    t.string "uri_hash", null: false
    t.string "authority"
    t.string "term_type", null: false
    t.text "custom_fields"
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_terms_on_uid", unique: true
    t.index ["uri_hash", "vocabulary_id"], name: "index_terms_on_uri_hash_and_vocabulary_id", unique: true
    t.index ["vocabulary_id"], name: "index_terms_on_vocabulary_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.boolean "is_active", default: true, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid", null: false
    t.boolean "is_admin", default: false
    t.string "sort_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sort_name"], name: "index_users_on_sort_name"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  create_table "vocabularies", force: :cascade do |t|
    t.string "label", null: false
    t.string "string_key", null: false
    t.text "custom_fields"
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["string_key"], name: "index_vocabularies_on_string_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "parent_child_relationships", "digital_objects", column: "child_id"
  add_foreign_key "parent_child_relationships", "digital_objects", column: "parent_id"
  add_foreign_key "projects_publish_targets", "projects"
  add_foreign_key "projects_publish_targets", "publish_targets"
  add_foreign_key "publish_entries", "digital_objects"
  add_foreign_key "publish_entries", "publish_targets"
  add_foreign_key "publish_entries", "users", column: "published_by_id"
end
