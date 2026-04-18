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

ActiveRecord::Schema[8.1].define(version: 2026_04_18_193819) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customer_profiles", force: :cascade do |t|
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "identity_status", default: "unverified", null: false
    t.string "stripe_customer_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_customer_profiles_on_user_id"
  end

  create_table "developer_profiles", force: :cascade do |t|
    t.string "connect_onboarding_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.string "display_name"
    t.datetime "github_connected_at"
    t.string "github_uid"
    t.string "github_url"
    t.string "github_username"
    t.decimal "hourly_rate", precision: 8, scale: 2
    t.integer "onboarding_step", default: 1, null: false
    t.string "skill_tags", default: [], array: true
    t.string "stripe_connect_id"
    t.string "tagline"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "verification_status", default: "unverified", null: false
    t.index ["user_id"], name: "index_developer_profiles_on_user_id"
  end

  create_table "portfolio_submissions", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "project_url", null: false
    t.string "status", default: "pending", null: false
    t.string "tech_tags", default: [], array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_portfolio_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "identity_status", default: "unverified", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "roles", default: [], array: true
    t.string "stripe_identity_session_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["roles"], name: "index_users_on_roles", using: :gin
  end

  add_foreign_key "customer_profiles", "users"
  add_foreign_key "developer_profiles", "users"
  add_foreign_key "portfolio_submissions", "users"
end
