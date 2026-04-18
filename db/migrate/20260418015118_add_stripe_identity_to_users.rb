class AddStripeIdentityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_identity_session_id, :string
    add_column :users, :identity_status, :string, null: false, default: "unverified"
  end
end