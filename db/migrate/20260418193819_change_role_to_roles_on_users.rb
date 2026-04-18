class ChangeRoleToRolesOnUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :roles, :string, array: true, default: []
    add_index  :users, :roles, using: "gin"

    # Migrate existing role data
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(roles: [user.role].compact)
    end

    remove_column :users, :role, :string
  end
end