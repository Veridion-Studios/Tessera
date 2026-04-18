class CreateDeveloperProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :developer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name
      t.string :tagline
      t.string :stripe_connect_id
      t.string :connect_onboarding_status, null: false, default: "pending"
      t.string :verification_status, null: false, default: "unverified"
      t.decimal :hourly_rate, precision: 8, scale: 2
      t.string :skill_tags, array: true, default: []

      t.timestamps
    end
  end
end