class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid   :user_id,    null: false
      t.string :subject,    null: false
      t.string :status,     null: false, default: "open"   # open | closed | waiting
      t.string :priority,   null: false, default: "normal" # low | normal | high | urgent
      t.uuid   :assigned_to_id                             # admin user
      t.datetime :last_message_at
      t.timestamps
    end

    add_index :conversations, :user_id
    add_index :conversations, :status
    add_index :conversations, :assigned_to_id
    add_foreign_key :conversations, :users
  end
end