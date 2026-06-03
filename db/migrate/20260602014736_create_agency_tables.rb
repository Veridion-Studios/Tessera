# db/migrate/TIMESTAMP_create_agency_tables.rb
class CreateAgencyTables < ActiveRecord::Migration[8.1]
  def change
    create_table :agencies, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :name,    null: false
      t.text   :bio
      t.string :website_url
      t.string :logo_url
      t.string :stripe_connect_id   # agency-level Connect account (optional)
      t.timestamps
    end

    create_table :agency_memberships, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :agency, null: false, foreign_key: true, type: :uuid
      t.references :user,   null: false, foreign_key: true, type: :uuid
      t.string  :role,       default: "member", null: false  # owner | admin | member
      t.string  :title        # e.g. "Senior Engineer", "Designer"
      t.text    :internal_notes
      t.decimal :revenue_share_pct, precision: 5, scale: 4, default: 0
      t.datetime :invited_at
      t.datetime :accepted_at
      t.datetime :deactivated_at
      t.timestamps
    end

    add_index :agency_memberships, [:agency_id, :user_id], unique: true
    add_index :agency_memberships, :role

    # Link projects to an agency (optional — a project can still belong to a solo developer)
    add_column :projects, :agency_id, :uuid, null: true
    add_foreign_key :projects, :agencies
    add_index :projects, :agency_id
  end
end