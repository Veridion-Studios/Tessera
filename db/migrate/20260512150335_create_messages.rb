class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid   :conversation_id, null: false
      t.uuid   :author_id,       null: false   # always a User
      t.string :author_type,     null: false, default: "User"
      t.string :source,          null: false, default: "web" # web | email
      t.boolean :internal,       null: false, default: false # admin-only notes
      t.timestamps
    end

    add_index :messages, :conversation_id
    add_foreign_key :messages, :conversations
  end
end