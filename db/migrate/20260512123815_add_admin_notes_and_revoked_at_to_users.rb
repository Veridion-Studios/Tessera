class AddAdminNotesAndRevokedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin_notes,          :text
    add_column :users, :identity_revoked_at,  :datetime
    add_column :users, :suspended_at,         :datetime
    add_column :users, :suspension_reason,    :string
  end
end