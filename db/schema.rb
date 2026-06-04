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

ActiveRecord::Schema[8.1].define(version: 2026_06_04_114717) do
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

  create_table "agencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "bio"
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.date "founded_on"
    t.string "logo_url"
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.string "slug"
    t.string "stripe_connect_id"
    t.string "tagline"
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private", null: false
    t.string "website_url"
    t.index ["owner_id"], name: "index_agencies_on_owner_id"
    t.index ["slug"], name: "index_agencies_on_slug", unique: true
  end

  create_table "agency_discussion_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.uuid "discussion_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_agency_discussion_messages_on_author_id"
    t.index ["discussion_id"], name: "index_agency_discussion_messages_on_discussion_id"
  end

  create_table "agency_discussions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agency_id", null: false
    t.uuid "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_reply_at"
    t.boolean "pinned", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "internal", null: false
    t.index ["agency_id"], name: "index_agency_discussions_on_agency_id"
    t.index ["author_id"], name: "index_agency_discussions_on_author_id"
  end

  create_table "agency_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agency_id", null: false
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.datetime "updated_at", null: false
    t.uuid "uploader_id", null: false
    t.string "visibility", default: "internal", null: false
    t.index ["agency_id"], name: "index_agency_files_on_agency_id"
    t.index ["uploader_id"], name: "index_agency_files_on_uploader_id"
  end

  create_table "agency_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.uuid "agency_id", null: false
    t.string "bench_status", default: "unavailable"
    t.integer "capacity_pct", default: 0
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.text "internal_notes"
    t.datetime "invited_at"
    t.decimal "revenue_share_pct", precision: 5, scale: 4, default: "0.0"
    t.string "role", default: "member", null: false
    t.string "specialty_tags", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["agency_id", "user_id"], name: "index_agency_memberships_on_agency_id_and_user_id", unique: true
    t.index ["agency_id"], name: "index_agency_memberships_on_agency_id"
    t.index ["role"], name: "index_agency_memberships_on_role"
    t.index ["user_id"], name: "index_agency_memberships_on_user_id"
  end

  create_table "agency_milestones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agency_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "position", default: 0, null: false
    t.uuid "project_id"
    t.string "status", default: "planned", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id", "position"], name: "index_agency_milestones_on_agency_id_and_position"
    t.index ["agency_id"], name: "index_agency_milestones_on_agency_id"
  end

  create_table "agency_proposals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agency_id", null: false
    t.datetime "created_at", null: false
    t.text "pitch"
    t.decimal "proposed_amount", precision: 10, scale: 2
    t.string "proposed_timeline"
    t.uuid "quote_request_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["agency_id", "quote_request_id"], name: "index_agency_proposals_on_agency_id_and_quote_request_id", unique: true
    t.index ["agency_id"], name: "index_agency_proposals_on_agency_id"
    t.index ["quote_request_id"], name: "index_agency_proposals_on_quote_request_id"
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
    t.string "availability", default: "open"
    t.text "bio"
    t.string "connect_onboarding_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "github_access_token"
    t.datetime "github_connected_at"
    t.string "github_uid"
    t.string "github_url"
    t.string "github_username"
    t.decimal "hourly_rate", precision: 8, scale: 2
    t.string "linear_access_token"
    t.string "linear_team_id"
    t.string "linear_team_name"
    t.string "linear_workspace_name"
    t.string "location"
    t.integer "onboarding_step", default: 1, null: false
    t.string "skill_tags", default: [], array: true
    t.string "stripe_connect_id"
    t.string "tagline"
    t.string "twitter_handle"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "verification_status", default: "unverified", null: false
    t.string "website_url"
  end

  create_table "devlog_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.text "body", null: false
    t.string "commit_sha"
    t.string "commit_url"
    t.datetime "created_at", null: false
    t.string "kind", default: "update"
    t.string "linear_issue_id"
    t.string "linear_issue_title"
    t.string "linear_issue_url"
    t.uuid "milestone_id"
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible_to_customer", default: true
    t.index ["author_id"], name: "index_devlog_entries_on_author_id"
    t.index ["milestone_id"], name: "index_devlog_entries_on_milestone_id"
    t.index ["project_id", "created_at"], name: "index_devlog_entries_on_project_id_and_created_at"
    t.index ["project_id"], name: "index_devlog_entries_on_project_id"
  end

  create_table "escrow_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.uuid "milestone_id"
    t.string "note"
    t.uuid "project_id", null: false
    t.string "stripe_id"
    t.datetime "updated_at", null: false
    t.index ["milestone_id"], name: "index_escrow_transactions_on_milestone_id"
    t.index ["project_id"], name: "index_escrow_transactions_on_project_id"
  end

  create_table "invoice_line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.uuid "invoice_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_amount", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "usd"
    t.uuid "developer_id", null: false
    t.date "due_date"
    t.text "memo"
    t.datetime "next_due_at"
    t.string "number"
    t.datetime "paid_at"
    t.string "payment_method"
    t.uuid "project_id"
    t.string "recurrence_interval"
    t.boolean "recurring", default: false
    t.datetime "sent_at"
    t.string "status", default: "draft", null: false
    t.string "stripe_customer_id"
    t.string "stripe_invoice_id"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate", precision: 5, scale: 4, default: "0.0"
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.datetime "voided_at"
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["developer_id"], name: "index_invoices_on_developer_id"
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["project_id"], name: "index_invoices_on_project_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["stripe_invoice_id"], name: "index_invoices_on_stripe_invoice_id", unique: true, where: "(stripe_invoice_id IS NOT NULL)"
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

  create_table "project_milestones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.datetime "paid_at"
    t.integer "position", default: 0, null: false
    t.uuid "project_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_transfer_id"
    t.datetime "submitted_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "position"], name: "index_project_milestones_on_project_id_and_position"
    t.index ["project_id"], name: "index_project_milestones_on_project_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agency_id"
    t.decimal "amount_held", precision: 10, scale: 2, default: "0.0"
    t.decimal "amount_released", precision: 10, scale: 2, default: "0.0"
    t.datetime "cancelled_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.uuid "customer_id", null: false
    t.text "description"
    t.uuid "developer_id", null: false
    t.date "due_date"
    t.string "escrow_status", default: "unfunded"
    t.string "payment_type", default: "milestone", null: false
    t.decimal "platform_fee_pct", precision: 5, scale: 4, default: "0.05"
    t.uuid "quote_request_id", null: false
    t.datetime "started_at"
    t.string "status", default: "active", null: false
    t.jsonb "stripe_metadata", default: {}
    t.string "stripe_payment_intent_id"
    t.string "title", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_projects_on_agency_id"
    t.index ["customer_id"], name: "index_projects_on_customer_id"
    t.index ["developer_id"], name: "index_projects_on_developer_id"
    t.index ["escrow_status"], name: "index_projects_on_escrow_status"
    t.index ["quote_request_id"], name: "index_projects_on_quote_request_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["stripe_metadata"], name: "index_projects_on_stripe_metadata", using: :gin
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

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "cancelled_at"
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "usd"
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.text "description"
    t.uuid "developer_id", null: false
    t.string "interval", default: "month", null: false
    t.string "name", null: false
    t.text "notes"
    t.datetime "paused_at"
    t.string "status", default: "active", null: false
    t.string "stripe_price_id"
    t.string "stripe_product_id"
    t.string "stripe_subscription_id"
    t.datetime "trial_end"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
    t.index ["developer_id"], name: "index_subscriptions_on_developer_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true, where: "(stripe_subscription_id IS NOT NULL)"
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
    t.integer "identity_verification_attempts", default: 0
    t.string "legal_first_name"
    t.string "legal_last_name"
    t.string "preferred_first_name"
    t.string "preferred_last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "stripe_identity_session_id"
    t.jsonb "stripe_identity_session_ids", default: []
    t.datetime "suspended_at"
    t.string "suspension_reason"
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "webauthn_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.check_constraint "identity_status::text = ANY (ARRAY['unverified'::character varying, 'pending'::character varying, 'verified'::character varying, 'requires_input'::character varying, 'locked'::character varying]::text[])", name: "chk_users_identity_status"
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
  add_foreign_key "agencies", "users", column: "owner_id"
  add_foreign_key "agency_discussion_messages", "agency_discussions", column: "discussion_id"
  add_foreign_key "agency_discussion_messages", "users", column: "author_id"
  add_foreign_key "agency_discussions", "agencies"
  add_foreign_key "agency_discussions", "users", column: "author_id"
  add_foreign_key "agency_files", "agencies"
  add_foreign_key "agency_files", "users", column: "uploader_id"
  add_foreign_key "agency_memberships", "agencies"
  add_foreign_key "agency_memberships", "users"
  add_foreign_key "agency_milestones", "agencies"
  add_foreign_key "agency_proposals", "agencies"
  add_foreign_key "agency_proposals", "quote_requests"
  add_foreign_key "conversations", "users"
  add_foreign_key "customer_profiles", "users"
  add_foreign_key "developer_profiles", "users"
  add_foreign_key "devlog_entries", "project_milestones", column: "milestone_id"
  add_foreign_key "devlog_entries", "projects"
  add_foreign_key "devlog_entries", "users", column: "author_id"
  add_foreign_key "escrow_transactions", "project_milestones", column: "milestone_id"
  add_foreign_key "escrow_transactions", "projects"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "projects"
  add_foreign_key "invoices", "users", column: "client_id"
  add_foreign_key "invoices", "users", column: "developer_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "passkeys", "users"
  add_foreign_key "portfolio_submissions", "users"
  add_foreign_key "project_milestones", "projects"
  add_foreign_key "projects", "agencies"
  add_foreign_key "projects", "quote_requests"
  add_foreign_key "projects", "users", column: "customer_id"
  add_foreign_key "projects", "users", column: "developer_id"
  add_foreign_key "quote_milestones", "quote_requests"
  add_foreign_key "quote_milestones", "users", column: "proposed_by_id"
  add_foreign_key "quote_requests", "users", column: "customer_id"
  add_foreign_key "quote_requests", "users", column: "developer_id"
  add_foreign_key "quote_thread_messages", "quote_requests"
  add_foreign_key "quote_thread_messages", "users", column: "author_id"
  add_foreign_key "subscriptions", "users", column: "client_id"
  add_foreign_key "subscriptions", "users", column: "developer_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
