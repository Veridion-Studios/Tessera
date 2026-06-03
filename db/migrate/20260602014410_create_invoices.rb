# db/migrate/TIMESTAMP_create_invoices.rb
class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :developer, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :client,    null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :project,   null: true,  foreign_key: true,                 type: :uuid

      t.string  :stripe_invoice_id
      t.string  :stripe_customer_id
      t.string  :number
      t.string  :status,       default: "draft", null: false
      t.decimal :subtotal,     precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax_rate,     precision: 5,  scale: 4, default: 0
      t.decimal :total,        precision: 10, scale: 2, null: false, default: 0
      t.string  :currency,     default: "usd"
      t.text    :memo
      t.date    :due_date
      t.datetime :sent_at
      t.datetime :paid_at
      t.datetime :voided_at
      t.string  :payment_method   # stripe | manual | other
      t.boolean :recurring,       default: false
      t.string  :recurrence_interval  # month | week | year
      t.datetime :next_due_at

      t.timestamps
    end

    create_table :invoice_line_items, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :invoice, null: false, foreign_key: true, type: :uuid
      t.string  :description, null: false
      t.integer :quantity,    null: false, default: 1
      t.decimal :unit_amount, precision: 10, scale: 2, null: false
      t.decimal :amount,      precision: 10, scale: 2, null: false
      t.timestamps
    end

    add_index :invoices, :stripe_invoice_id, unique: true, where: "stripe_invoice_id IS NOT NULL"
    add_index :invoices, :status
    add_index :invoices, :due_date
  end
end