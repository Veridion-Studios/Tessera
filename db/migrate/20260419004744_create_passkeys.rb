class CreatePasskeys < ActiveRecord::Migration[8.1]
  def change
    create_table :passkeys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label
      t.string :external_id
      t.text :public_key
      t.integer :sign_count
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
