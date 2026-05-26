class UpdateIdentityStatusCheckConstraint < ActiveRecord::Migration[7.1]
  def up
    remove_check_constraint :users, name: "chk_users_identity_status"
    add_check_constraint :users, "identity_status IN ('unverified', 'pending', 'verified', 'requires_input', 'locked')", name: "chk_users_identity_status"
  end

  def down
    remove_check_constraint :users, name: "chk_users_identity_status"
    add_check_constraint :users, "identity_status IN ('unverified', 'pending', 'verified', 'requires_input')", name: "chk_users_identity_status"
  end
end
