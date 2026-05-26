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

ActiveRecord::Schema[8.1].define(version: 2026_05_26_150521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "action_mailbox_inbound_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_to_id"
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.string "priority", default: "normal", null: false
    t.string "status", default: "open", null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["assigned_to_id"], name: "index_conversations_on_assigned_to_id"
    t.index ["status"], name: "index_conversations_on_status"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "identity_status", default: "unverified", null: false
    t.string "stripe_customer_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "developer_profiles", force: :cascade do |t|
    t.string "connect_onboarding_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "github_access_token"
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
    t.uuid "user_id", null: false
    t.string "verification_status", default: "unverified", null: false
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.string "author_type", default: "User", null: false
    t.uuid "conversation_id", null: false
    t.datetime "created_at", null: false
    t.boolean "internal", default: false, null: false
    t.string "source", default: "web", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "noticed_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count", default: 0, null: false
    t.jsonb "params"
    t.uuid "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.datetime "read_at", precision: nil
    t.uuid "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "label"
    t.datetime "last_used_at"
    t.text "public_key"
    t.integer "sign_count"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "portfolio_submissions", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "github_repo_url", null: false
    t.string "project_demo_url"
    t.string "status", default: "pending", null: false
    t.string "tech_tags", default: [], array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["github_repo_url"], name: "index_portfolio_submissions_on_github_repo_url"
  end

  create_table "quote_milestones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "position", default: 0, null: false
    t.uuid "proposed_by_id", null: false
    t.uuid "quote_request_id", null: false
    t.string "status", default: "proposed", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_request_id", "position"], name: "index_quote_milestones_on_quote_request_id_and_position"
  end

  create_table "quote_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.decimal "agreed_amount", precision: 10, scale: 2
    t.string "agreed_timeline"
    t.decimal "budget_max", precision: 10, scale: 2
    t.decimal "budget_min", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.uuid "customer_id", null: false
    t.datetime "declined_at"
    t.text "description", null: false
    t.uuid "developer_id", null: false
    t.string "engagement_type", default: "fixed", null: false
    t.date "estimated_end_date"
    t.date "estimated_start_date"
    t.datetime "expires_at"
    t.datetime "responded_at"
    t.string "status", default: "submitted", null: false
    t.datetime "submitted_at"
    t.string "tech_tags", default: [], array: true
    t.string "timeline", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at"
    t.index ["customer_id"], name: "index_quote_requests_on_customer_id"
    t.index ["developer_id"], name: "index_quote_requests_on_developer_id"
    t.index ["status"], name: "index_quote_requests_on_status"
  end

  create_table "quote_thread_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "kind", default: "message", null: false
    t.decimal "proposed_amount", precision: 10, scale: 2
    t.date "proposed_end_date"
    t.date "proposed_start_date"
    t.string "proposed_timeline"
    t.uuid "quote_request_id", null: false
    t.boolean "read_by_customer", default: false, null: false
    t.boolean "read_by_developer", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_quote_thread_messages_on_author_id"
    t.index ["quote_request_id"], name: "index_quote_thread_messages_on_quote_request_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "identity_revoked_at"
    t.string "identity_status", default: "unverified", null: false
    t.string "legal_first_name"
    t.string "legal_last_name"
    t.string "preferred_first_name"
    t.string "preferred_last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "stripe_identity_session_id"
    t.datetime "suspended_at"
    t.string "suspension_reason"
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "identity_status::text = ANY (ARRAY['unverified'::character varying, 'pending'::character varying, 'verified'::character varying, 'requires_input'::character varying]::text[])", name: "chk_users_identity_status"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.string "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "users"
  add_foreign_key "customer_profiles", "users"
  add_foreign_key "developer_profiles", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "passkeys", "users"
  add_foreign_key "portfolio_submissions", "users"
  add_foreign_key "quote_milestones", "quote_requests"
  add_foreign_key "quote_milestones", "users", column: "proposed_by_id"
  add_foreign_key "quote_requests", "users", column: "customer_id"
  add_foreign_key "quote_requests", "users", column: "developer_id"
  add_foreign_key "quote_thread_messages", "quote_requests"
  add_foreign_key "quote_thread_messages", "users", column: "author_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
