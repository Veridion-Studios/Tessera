class AddIdentityStatusCheckConstraintToUsers < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint :users,
      "identity_status IN ('unverified', 'pending', 'verified', 'requires_input')",
      name: "chk_users_identity_status"
  end

  def down
    remove_check_constraint :users, name: "chk_users_identity_status"
  end
end