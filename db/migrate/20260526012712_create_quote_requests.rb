class CreateQuoteRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_requests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      # Parties
      t.uuid   :customer_id,  null: false   # User (customer role)
      t.uuid   :developer_id, null: false   # User (developer role)

      # Project brief
      t.string  :title,           null: false
      t.text    :description,     null: false
      t.string  :tech_tags,       array: true, default: []

      # Budget & timeline (customer's initial ask)
      t.decimal :budget_min,      precision: 10, scale: 2
      t.decimal :budget_max,      precision: 10, scale: 2
      t.string  :timeline,        null: false   # e.g. "4-6 weeks"
      t.string  :engagement_type, null: false, default: "fixed"  # fixed | hourly | retainer

      # Developer's agreed terms (populated on acceptance)
      t.decimal :agreed_amount,   precision: 10, scale: 2
      t.string  :agreed_timeline
      t.date    :estimated_start_date
      t.date    :estimated_end_date

      # Status machine
      t.string  :status, null: false, default: "submitted"

      # Timestamps
      t.datetime :submitted_at
      t.datetime :viewed_at
      t.datetime :responded_at
      t.datetime :accepted_at
      t.datetime :declined_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :quote_requests, :customer_id
    add_index :quote_requests, :developer_id
    add_index :quote_requests, :status
    add_foreign_key :quote_requests, :users, column: :customer_id
    add_foreign_key :quote_requests, :users, column: :developer_id
  end
end