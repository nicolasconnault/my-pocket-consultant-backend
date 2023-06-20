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

ActiveRecord::Schema.define(version: 2023_06_19_064605) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "country_id"
    t.bigint "user_id"
    t.string "street1"
    t.string "street2"
    t.string "unit"
    t.string "suburb"
    t.float "latitude"
    t.float "longitude"
    t.string "phone"
    t.string "fax"
    t.string "state"
    t.string "postcode"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.bigint "company_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_category_id"], name: "index_companies_on_company_category_id"
  end

  create_table "company_categories", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_news_types", id: :serial, force: :cascade do |t|
    t.integer "news_type_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_news_types_on_company_id"
    t.index ["news_type_id"], name: "index_company_news_types_on_news_type_id"
  end

  create_table "company_tutorials", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.integer "tutorial_category_id"
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_tutorials_on_company_id"
    t.index ["tutorial_category_id"], name: "index_company_tutorials_on_tutorial_category_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news_items", id: :serial, force: :cascade do |t|
    t.integer "news_type_id"
    t.integer "subscription_id"
    t.string "title"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.float "discountedPrice"
    t.float "regularPrice"
    t.index ["news_type_id"], name: "index_news_items_on_news_type_id"
    t.index ["subscription_id"], name: "index_news_items_on_subscription_id"
  end

  create_table "news_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "news_item_id"
    t.date "date_read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["news_item_id"], name: "index_notifications_on_news_item_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "push_notification_devices", force: :cascade do |t|
    t.string "device_type"
    t.string "push_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_apns_apps", force: :cascade do |t|
    t.text "apns_dev_cert"
    t.text "apns_prod_cert"
    t.boolean "sandbox_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_gcm_apps", force: :cascade do |t|
    t.string "gcm_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_mpns_apps", force: :cascade do |t|
    t.text "cert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_notifications", force: :cascade do |t|
    t.text "destinations"
    t.integer "app_id"
    t.string "app_type"
    t.text "data"
    t.text "results"
    t.integer "success"
    t.integer "failed"
    t.boolean "sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id", "app_type", "sent"], name: "app_and_sent_index_on_rails_push_notifications"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "subscription_user_call_reminders", force: :cascade do |t|
    t.bigint "subscription_user_id"
    t.string "title"
    t.datetime "call_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_user_id"], name: "index_subscription_user_call_reminders_on_subscription_user_id"
  end

  create_table "subscription_user_news_types", force: :cascade do |t|
    t.bigint "subscription_user_id"
    t.bigint "news_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["news_type_id"], name: "index_subscription_user_news_types_on_news_type_id"
    t.index ["subscription_user_id"], name: "index_subscription_user_news_types_on_subscription_user_id"
  end

  create_table "subscription_user_notes", force: :cascade do |t|
    t.bigint "subscription_user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["subscription_user_id"], name: "index_subscription_user_notes_on_subscription_user_id"
  end

  create_table "subscription_users", force: :cascade do |t|
    t.bigint "subscription_id"
    t.bigint "user_id"
    t.boolean "potential_recruit", default: false
    t.boolean "potential_host", default: false
    t.boolean "current_host", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_users_on_subscription_id"
    t.index ["user_id"], name: "index_subscription_users_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.boolean "active"
    t.string "website_url"
    t.string "facebook_url"
    t.string "twitter_url"
    t.index ["company_id"], name: "index_subscriptions_on_company_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tutorial_categories", id: :serial, force: :cascade do |t|
    t.integer "company_category_id"
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_category_id"], name: "index_tutorial_categories_on_company_category_id"
  end

  create_table "tutorial_steps", id: :serial, force: :cascade do |t|
    t.integer "company_tutorial_id"
    t.string "title", null: false
    t.string "description", null: false
    t.integer "sort_order", default: 1
    t.boolean "video", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_tutorial_id"], name: "index_tutorial_steps_on_company_tutorial_id"
  end

  create_table "user_devices", force: :cascade do |t|
    t.bigint "push_notification_device_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["push_notification_device_id"], name: "index_user_devices_on_push_notification_device_id"
    t.index ["user_id"], name: "index_user_devices_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "password"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_companies", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.bigint "consultant_id"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_companies_on_company_id"
    t.index ["consultant_id"], name: "index_users_companies_on_consultant_id"
    t.index ["user_id"], name: "index_users_companies_on_user_id"
  end

  create_table "users_company_news_types", id: :serial, force: :cascade do |t|
    t.integer "news_type_id"
    t.integer "users_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["news_type_id"], name: "index_users_company_news_types_on_news_type_id"
    t.index ["users_company_id"], name: "index_users_company_news_types_on_users_company_id"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "users"
  add_foreign_key "companies", "company_categories"
  add_foreign_key "company_news_types", "companies"
  add_foreign_key "company_news_types", "news_types"
  add_foreign_key "company_tutorials", "companies"
  add_foreign_key "company_tutorials", "tutorial_categories"
  add_foreign_key "news_items", "news_types"
  add_foreign_key "news_items", "subscriptions"
  add_foreign_key "notifications", "news_items"
  add_foreign_key "notifications", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "subscription_user_call_reminders", "subscription_users"
  add_foreign_key "subscription_user_news_types", "news_types"
  add_foreign_key "subscription_user_news_types", "subscription_users"
  add_foreign_key "subscription_user_notes", "subscription_users"
  add_foreign_key "subscription_users", "subscriptions"
  add_foreign_key "subscription_users", "users"
  add_foreign_key "subscriptions", "companies"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "tutorial_categories", "company_categories"
  add_foreign_key "tutorial_steps", "company_tutorials"
  add_foreign_key "user_devices", "push_notification_devices"
  add_foreign_key "user_devices", "users"
  add_foreign_key "users_companies", "companies"
  add_foreign_key "users_companies", "users"
  add_foreign_key "users_companies", "users", column: "consultant_id"
  add_foreign_key "users_company_news_types", "news_types"
  add_foreign_key "users_company_news_types", "users_companies"
end
