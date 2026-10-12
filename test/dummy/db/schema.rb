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

ActiveRecord::Schema[8.1].define(version: 301111010) do
  create_table "lesli_accounts", force: :cascade do |t|
    t.string "status", null: false
    t.string "name"
    t.string "email", null: false
    t.string "region", default: "america"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["deleted_at"], name: "index_lesli_accounts_on_deleted_at"
    t.index ["email"], name: "index_lesli_accounts_on_email", unique: true
    t.index ["user_id"], name: "index_lesli_accounts_on_user_id"
  end

  create_table "lesli_calendar_accounts", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0, null: false
    t.datetime "enabled_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id", null: false
    t.index ["account_id"], name: "index_lesli_calendar_accounts_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_calendar_accounts_on_deleted_at"
  end

  create_table "lesli_calendar_calendars", force: :cascade do |t|
    t.string "name"
    t.string "color", default: "0d52bf"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "account_id"
    t.index ["account_id"], name: "index_lesli_calendar_calendars_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_calendar_calendars_on_deleted_at"
    t.index ["user_id"], name: "index_lesli_calendar_calendars_on_user_id"
  end

  create_table "lesli_calendar_event_attendants", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "event_id"
    t.index ["confirmed_at"], name: "index_lesli_calendar_event_attendants_on_confirmed_at"
    t.index ["deleted_at"], name: "index_lesli_calendar_event_attendants_on_deleted_at"
    t.index ["event_id"], name: "index_lesli_calendar_event_attendants_on_event_id"
    t.index ["user_id"], name: "index_lesli_calendar_event_attendants_on_user_id"
  end

  create_table "lesli_calendar_events", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.string "url"
    t.string "location"
    t.string "status"
    t.boolean "public"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.integer "calendar_id"
    t.integer "user_id"
    t.index ["account_id"], name: "index_lesli_calendar_events_on_account_id"
    t.index ["calendar_id"], name: "index_lesli_calendar_events_on_calendar_id"
    t.index ["deleted_at"], name: "index_lesli_calendar_events_on_deleted_at"
    t.index ["end_at"], name: "index_lesli_calendar_events_on_end_at"
    t.index ["public"], name: "index_lesli_calendar_events_on_public"
    t.index ["start_at"], name: "index_lesli_calendar_events_on_start_at"
    t.index ["status"], name: "index_lesli_calendar_events_on_status"
    t.index ["user_id"], name: "index_lesli_calendar_events_on_user_id"
  end

  create_table "lesli_resources", force: :cascade do |t|
    t.string "identifier"
    t.string "label"
    t.string "engine"
    t.string "action"
    t.string "route"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.index ["deleted_at"], name: "index_lesli_resources_on_deleted_at"
    t.index ["parent_id"], name: "index_lesli_resources_on_parent_id"
  end

  create_table "lesli_roles", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.boolean "active"
    t.string "path_default"
    t.boolean "path_limited"
    t.boolean "isolated", default: false
    t.integer "permission_level", default: 10
    t.datetime "deployed_at"
    t.datetime "modified_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_lesli_roles_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_roles_on_deleted_at"
  end

  create_table "lesli_users", force: :cascade do |t|
    t.string "uid", null: false
    t.boolean "active", default: true, null: false
    t.string "alias"
    t.string "title"
    t.string "salutation"
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "locked_until"
    t.string "unlock_token"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "password_expiration_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.string "telephone"
    t.string "telephone_confirmation_token"
    t.datetime "telephone_confirmation_sent_at"
    t.datetime "telephone_confirmed_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id", "active"], name: "index_lesli_users_on_account_id_and_active"
    t.index ["account_id", "confirmed_at"], name: "index_lesli_users_on_account_id_and_confirmed_at"
    t.index ["account_id", "created_at"], name: "index_lesli_users_on_account_id_and_created_at"
    t.index ["account_id", "deleted_at"], name: "index_lesli_users_on_account_id_and_deleted_at"
    t.index ["account_id", "last_sign_in_at"], name: "index_lesli_users_on_account_id_and_last_sign_in_at"
    t.index ["account_id", "locked_at"], name: "index_lesli_users_on_account_id_and_locked_at"
    t.index ["account_id", "locked_until"], name: "index_lesli_users_on_account_id_and_locked_until"
    t.index ["account_id"], name: "index_lesli_users_on_account_id"
    t.index ["confirmation_token"], name: "index_lesli_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_lesli_users_on_deleted_at"
    t.index ["email"], name: "index_lesli_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_lesli_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_lesli_users_on_uid", unique: true
    t.index ["unlock_token"], name: "index_lesli_users_on_unlock_token", unique: true
  end

  add_foreign_key "lesli_accounts", "lesli_users", column: "user_id"
  add_foreign_key "lesli_calendar_accounts", "lesli_accounts", column: "account_id"
  add_foreign_key "lesli_calendar_calendars", "lesli_calendar_accounts", column: "account_id"
  add_foreign_key "lesli_calendar_calendars", "lesli_users", column: "user_id"
  add_foreign_key "lesli_calendar_event_attendants", "lesli_calendar_events", column: "event_id"
  add_foreign_key "lesli_calendar_event_attendants", "lesli_users", column: "user_id"
  add_foreign_key "lesli_calendar_events", "lesli_accounts", column: "account_id"
  add_foreign_key "lesli_calendar_events", "lesli_calendar_calendars", column: "calendar_id"
  add_foreign_key "lesli_calendar_events", "lesli_users", column: "user_id"
  add_foreign_key "lesli_resources", "lesli_resources", column: "parent_id"
  add_foreign_key "lesli_roles", "lesli_accounts", column: "account_id"
  add_foreign_key "lesli_users", "lesli_accounts", column: "account_id"
end
