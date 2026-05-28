class CreateProjectsAndDevlogs < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :quote_request, type: :uuid, null: false, foreign_key: true
      t.references :developer,     type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :customer,      type: :uuid, null: false, foreign_key: { to_table: :users }

      t.string  :title,            null: false
      t.text    :description
      t.string  :status,           null: false, default: "active"
      t.string  :payment_type,     null: false, default: "milestone" # milestone | fixed
      t.decimal :total_amount,     precision: 10, scale: 2, null: false
      t.decimal :platform_fee_pct, precision: 5,  scale: 4, default: "0.05"

      # Stripe escrow
      t.string  :stripe_payment_intent_id
      t.string  :escrow_status,    default: "unfunded" # unfunded | funded | partially_released | released | refunded

      t.decimal :amount_held,      precision: 10, scale: 2, default: "0"
      t.decimal :amount_released,  precision: 10, scale: 2, default: "0"

      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.date     :due_date

      t.timestamps
      t.index :status
      t.index :escrow_status
    end

    create_table :project_milestones, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :project, type: :uuid, null: false, foreign_key: true
      t.string  :title,       null: false
      t.text    :description
      t.decimal :amount,      precision: 10, scale: 2, null: false
      t.integer :position,    default: 0, null: false
      t.string  :status,      null: false, default: "pending"
        # pending | in_progress | submitted | approved | paid | disputed
      t.date    :due_date
      t.datetime :submitted_at
      t.datetime :approved_at
      t.datetime :paid_at
      t.string  :stripe_transfer_id
      t.timestamps
      t.index [:project_id, :position]
    end

    create_table :devlog_entries, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :project,  type: :uuid, null: false, foreign_key: true
      t.references :author,   type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :milestone, type: :uuid, null: true,  foreign_key: { to_table: :project_milestones }

      t.text    :body,          null: false
      t.string  :kind,          default: "update" # update | commit | file | milestone_submit | milestone_approve
      t.string  :commit_sha
      t.string  :commit_url
      t.boolean :visible_to_customer, default: true
      t.timestamps
      t.index [:project_id, :created_at]
    end

    create_table :escrow_transactions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :project,   type: :uuid, null: false, foreign_key: true
      t.references :milestone, type: :uuid, null: true,  foreign_key: { to_table: :project_milestones }
      t.string  :kind,         null: false # fund | release | refund | fee
      t.decimal :amount,       precision: 10, scale: 2, null: false
      t.string  :stripe_id
      t.string  :note
      t.timestamps
    end
  end
end