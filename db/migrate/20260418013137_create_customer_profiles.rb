class CreateCustomerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name
      t.string :company_name
      t.string :identity_status, null: false, default: "unverified"
      t.string :stripe_customer_id

      t.timestamps
    end
  end
end