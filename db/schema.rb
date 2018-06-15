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

ActiveRecord::Schema.define(version: 20171129032836) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "street1"
    t.string   "street2"
    t.string   "unit"
    t.string   "suburb"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "phone"
    t.string   "fax"
    t.string  "state"
    t.string  "postcode"
    t.string   "timezone"
    t.index ["country_id"], name: "index_addresses_on_country_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "label", limit: 64, null: false
    t.integer "company_category_id"
    t.index ["company_category_id"], name: "index_companies_on_company_category_id", using: :btree
  end

  create_table "company_categories", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "label", limit: 64, null: false
  end

  create_table "users_companies", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id", null: false
    t.integer "consultant_id", null: true
    t.index ["user_id"], name: "index_user_companies_on_user_id", using: :btree
    t.index ["company_id"], name: "index_user_companies_on_company_id", using: :btree
    t.index ["consultant_id"], name: "index_user_companies_on_consultant_id", using: :btree
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "role_notification_types", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "wupee_notification_type_id"
    t.boolean  "email"
    t.boolean  "notify"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["role_id"], name: "index_role_notification_types_on_role_id", using: :btree
    t.index ["wupee_notification_type_id"], name: "index_role_notification_types_on_wupee_notification_type_id", using: :btree
  end
  
  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end
  
  create_table "settings", force: :cascade do |t|
    t.string   "name",       limit: 510,                    null: false
    t.text     "value",                                     null: false
    t.string   "status",     limit: 32,  default: "Active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  create_table "wupee_notification_type_configurations", force: :cascade do |t|
    t.integer  "notification_type_id"
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.integer  "value",                default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["notification_type_id"], name: "idx_wupee_notif_type_config_on_notification_type_id", using: :btree
    t.index ["receiver_type", "receiver_id"], name: "idx_wupee_notif_typ_config_on_receiver_type_and_receiver_id", using: :btree
  end

  create_table "wupee_notification_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_wupee_notification_types_on_name", unique: true, using: :btree
  end

  create_table "wupee_notifications", force: :cascade do |t|
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.string   "attached_object_type"
    t.integer  "attached_object_id"
    t.integer  "notification_type_id"
    t.boolean  "is_read",              default: false
    t.boolean  "is_sent",              default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "is_wanted",            default: true
  and

  add_foreign_key "addresses", "countries"
  add_foreign_key "companies", "company_categories"
  add_foreign_key "role_notification_types", "roles"
  add_foreign_key "role_notification_types", "wupee_notification_types"
  add_foreign_key "wupee_notification_type_configurations", "wupee_notification_types", column: "notification_type_id"
  add_foreign_key "wupee_notifications", "wupee_notification_types", column: "notification_type_id"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
  add_foreign_key "users_companies", "users", column: "user_id"
  add_foreign_key "users_companies", "companies"
end
