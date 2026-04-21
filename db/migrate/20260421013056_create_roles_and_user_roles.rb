# db/migrate/TIMESTAMP_create_roles_and_user_roles.rb
class CreateRolesAndUserRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :roles, :name, unique: true

    create_table :user_roles do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :role,  null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_roles, [:user_id, :role_id], unique: true

    remove_column :users, :roles, :string, array: true, default: []
  end
end