class CreateQuoteMilestones < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_milestones, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid    :quote_request_id, null: false
      t.uuid    :proposed_by_id,   null: false  # User who proposed it
      t.integer :position,         null: false, default: 0
      t.string  :title,            null: false
      t.text    :description
      t.decimal :amount,           precision: 10, scale: 2, null: false
      t.date    :due_date
      t.string  :status,           null: false, default: "proposed"
        # proposed | accepted | rejected | completed | paid

      t.timestamps
    end

    add_index :quote_milestones, [:quote_request_id, :position]
    add_foreign_key :quote_milestones, :quote_requests
    add_foreign_key :quote_milestones, :users, column: :proposed_by_id
  end
end