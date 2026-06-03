# db/migrate/TIMESTAMP_create_subscriptions.rb
class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :developer, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :client,    null: false, foreign_key: { to_table: :users }, type: :uuid

      t.string  :stripe_subscription_id
      t.string  :stripe_product_id
      t.string  :stripe_price_id
      t.string  :name,        null: false
      t.text    :description
      t.string  :status,      default: "active", null: false  # active | paused | cancelled | past_due
      t.string  :interval,    default: "month",  null: false  # month | year | week
      t.decimal :amount,      precision: 10, scale: 2, null: false
      t.string  :currency,    default: "usd"
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_end
      t.datetime :cancelled_at
      t.datetime :paused_at
      t.text    :notes

      t.timestamps
    end

    add_index :subscriptions, :stripe_subscription_id, unique: true, where: "stripe_subscription_id IS NOT NULL"
    add_index :subscriptions, :status
  end
end