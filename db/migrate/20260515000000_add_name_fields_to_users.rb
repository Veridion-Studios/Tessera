class AddNameFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :legal_first_name, :string
    add_column :users, :legal_last_name, :string
    add_column :users, :preferred_first_name, :string
    add_column :users, :preferred_last_name, :string
  end
end
