class ChangeUserIdToUuid < ActiveRecord::Migration[8.1]
  def up
    # Enable pgcrypto for gen_random_uuid()
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 1. Drop foreign keys that reference users.id
    remove_foreign_key :user_roles,           :users
    remove_foreign_key :passkeys,             :users
    remove_foreign_key :portfolio_submissions, :users
    remove_foreign_key :developer_profiles,   :users
    remove_foreign_key :customer_profiles,    :users

    # 2. Add a temporary uuid column on users
    add_column :users, :uuid, :uuid, default: "gen_random_uuid()", null: false

    # 3. Add uuid columns on all child tables (nullable for now)
    add_column :user_roles,            :user_uuid, :uuid
    add_column :passkeys,              :user_uuid, :uuid
    add_column :portfolio_submissions, :user_uuid, :uuid
    add_column :developer_profiles,   :user_uuid, :uuid
    add_column :customer_profiles,    :user_uuid, :uuid

    # 4. Populate child uuid columns from users.uuid
    execute <<~SQL
      UPDATE user_roles            SET user_uuid = users.uuid FROM users WHERE users.id = user_roles.user_id;
      UPDATE passkeys              SET user_uuid = users.uuid FROM users WHERE users.id = passkeys.user_id;
      UPDATE portfolio_submissions SET user_uuid = users.uuid FROM users WHERE users.id = portfolio_submissions.user_id;
      UPDATE developer_profiles   SET user_uuid = users.uuid FROM users WHERE users.id = developer_profiles.user_id;
      UPDATE customer_profiles    SET user_uuid = users.uuid FROM users WHERE users.id = customer_profiles.user_id;
    SQL

    # 5. Drop old integer id and rename uuid → id on users
    execute "ALTER TABLE users DROP CONSTRAINT users_pkey CASCADE;"
    remove_column :users, :id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    execute "ALTER TABLE users ALTER COLUMN id SET DEFAULT gen_random_uuid();"

    # 6. Swap child columns
    [
      :user_roles,
      :passkeys,
      :portfolio_submissions,
      :developer_profiles,
      :customer_profiles
    ].each do |table|
      remove_column table, :user_id
      rename_column table, :user_uuid, :user_id
      change_column_null table, :user_id, false
      add_foreign_key table, :users, column: :user_id, primary_key: :id
    end

    # 7. Fix PaperTrail versions — whodunnit is a string, already fine.
    #    item_id is also a string, so no column change needed there.
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end