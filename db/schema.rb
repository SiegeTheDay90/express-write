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

ActiveRecord::Schema[7.0].define(version: 2024_02_13_172009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "letters", force: :cascade do |t|
    t.text "body", null: false
    t.text "config", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "listing_id"
    t.bigint "user_id"
    t.boolean "helpful"
    t.index ["listing_id"], name: "index_letters_on_listing_id"
    t.index ["user_id"], name: "index_letters_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "company", null: false
    t.string "job_title", null: false
    t.text "job_description", default: ""
    t.string "requirements", default: [], array: true
    t.string "benefits", default: [], array: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "title", null: false
    t.string "industry", default: ""
    t.text "aboutme", default: ""
    t.text "skills", default: [], array: true
    t.text "education", default: [], array: true
    t.text "experience", default: [], array: true
    t.string "projects", default: [], array: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.boolean "complete", default: false
    t.boolean "ok"
    t.string "messages", default: ""
    t.string "resource_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.string "title"
    t.text "header", default: ""
    t.text "experience", default: "[]"
    t.text "education", default: "[]"
    t.text "links", default: "[]"
    t.text "skills", default: "[]"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "temp_letters", force: :cascade do |t|
    t.string "profile", null: false
    t.string "listing", null: false
    t.string "body", null: false
    t.string "secure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["secure_id"], name: "index_temp_letters_on_secure_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "username"
    t.string "session_token"
    t.integer "active_profile"
    t.string "email_token"
    t.string "unconfirmed_email"
    t.datetime "email_token_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_token"], name: "index_users_on_email_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["session_token"], name: "index_users_on_session_token"
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "letters", "users"
  add_foreign_key "listings", "users"
  add_foreign_key "resumes", "users"
end
