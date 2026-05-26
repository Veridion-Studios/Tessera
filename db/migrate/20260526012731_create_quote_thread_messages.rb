class CreateQuoteThreadMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_thread_messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid   :quote_request_id, null: false
      t.uuid   :author_id,        null: false  # User
      t.string :kind,             null: false, default: "message"
        # message | counter_proposal | acceptance | decline | milestone_proposal | system

      t.text    :body
      t.decimal :proposed_amount,   precision: 10, scale: 2
      t.string  :proposed_timeline
      t.date    :proposed_start_date
      t.date    :proposed_end_date

      t.boolean :read_by_customer,  default: false, null: false
      t.boolean :read_by_developer, default: false, null: false

      t.timestamps
    end

    add_index :quote_thread_messages, :quote_request_id
    add_index :quote_thread_messages, :author_id
    add_foreign_key :quote_thread_messages, :quote_requests
    add_foreign_key :quote_thread_messages, :users, column: :author_id
  end
end