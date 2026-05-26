class AddIdentityVerificationAttemptsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :identity_verification_attempts, :integer, default: 0
    add_column :users, :stripe_identity_session_ids, :jsonb, default: []
  end
end
