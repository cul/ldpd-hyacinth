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

ActiveRecord::Schema.define(version: 2019_03_19_163208) do

  create_table "database_entry_locks", force: :cascade do |t|
    t.string "lock_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.index ["lock_key"], name: "index_database_entry_locks_on_lock_key", unique: true
  end

  create_table "digital_object_records", force: :cascade do |t|
    t.string "uid", null: false
    t.string "metadata_location_uri"
    t.string "optimistic_lock_token"
    t.index ["uid"], name: "index_digital_object_records_on_uid", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "string_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.index ["string_key"], name: "index_groups_on_string_key", unique: true
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id"
    t.index ["user_id", "group_id"], name: "index_groups_users_on_user_id_and_group_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "group_id"
    t.string "action", null: false
    t.string "subject"
    t.string "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_permissions_on_group_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_url"
    t.index ["display_label"], name: "index_projects_on_display_label", unique: true
    t.index ["string_key"], name: "index_projects_on_string_key", unique: true
  end

  create_table "publish_targets", force: :cascade do |t|
    t.integer "project_id"
    t.string "string_key", null: false
    t.string "display_label", null: false
    t.text "publish_url", null: false
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_publish_targets_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.boolean "is_active", default: true, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
