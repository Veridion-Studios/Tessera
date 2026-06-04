class ExpandAgencyPlatform < ActiveRecord::Migration[8.1]
  def change
    # ── Agencies: branding + white-label slug ────────────────────────────
    add_column :agencies, :slug,             :string
    add_column :agencies, :tagline,          :string
    add_column :agencies, :cover_image_url,  :string
    add_column :agencies, :founded_on,       :date
    add_column :agencies, :visibility,       :string, default: "private", null: false
    # visibility: "private" | "public" | "whitelabel"

    add_index :agencies, :slug, unique: true

    # ── Agency memberships: capacity + bench ────────────────────────────
    add_column :agency_memberships, :specialty_tags,    :string,  array: true, default: []
    add_column :agency_memberships, :bench_status,       :string,  default: "unavailable"
    # bench_status: "available_now" | "available_soon" | "unavailable"
    add_column :agency_memberships, :capacity_pct,       :integer, default: 0
    # 0-100 — percentage of this member's time currently committed
    change_column :agency_memberships, :revenue_share_pct,  :decimal, precision: 5, scale: 4, default: 0
    # 0.0000–1.0000 — e.g. 0.25 = 25% of agency revenue

    # ── Agency milestones ────────────────────────────────────────────────
    create_table :agency_milestones, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :agency,    null: false, foreign_key: true, type: :uuid
      t.string     :title,     null: false
      t.text       :description
      t.date       :due_date
      t.string     :status,    default: "planned", null: false
      # status: planned | in_progress | completed | cancelled
      t.integer    :position,  default: 0, null: false
      t.uuid       :project_id               # optional link to a project
      t.timestamps
    end

    add_index :agency_milestones, [:agency_id, :position]

    # ── Agency discussions (internal + client-facing) ────────────────────
    create_table :agency_discussions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :agency,     null: false, foreign_key: true, type: :uuid
      t.references :author,     null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string     :title,      null: false
      t.string     :visibility, default: "internal", null: false
      # visibility: "internal" | "client"
      t.boolean    :pinned,     default: false, null: false
      t.datetime   :last_reply_at
      t.timestamps
    end

    create_table :agency_discussion_messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :discussion, null: false,
                   foreign_key: { to_table: :agency_discussions }, type: :uuid
      t.references :author,     null: false, foreign_key: { to_table: :users }, type: :uuid
      t.text       :body,       null: false
      t.timestamps
    end

    # ── Agency files ─────────────────────────────────────────────────────
    create_table :agency_files, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :agency,   null: false, foreign_key: true, type: :uuid
      t.references :uploader, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string     :label,    null: false
      t.string     :visibility, default: "internal", null: false
      # visibility: "internal" | "client"
      t.timestamps
    end

    # ── Agency proposals (team bid on a quote request) ───────────────────
    create_table :agency_proposals, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :agency,        null: false, foreign_key: true, type: :uuid
      t.references :quote_request, null: false, foreign_key: true, type: :uuid
      t.text       :pitch
      t.decimal    :proposed_amount, precision: 10, scale: 2
      t.string     :proposed_timeline
      t.string     :status,  default: "draft", null: false
      # status: draft | submitted | accepted | declined | withdrawn
      t.datetime   :submitted_at
      t.timestamps
    end

    add_index :agency_proposals, [:agency_id, :quote_request_id], unique: true
  end
end