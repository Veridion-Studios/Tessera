class AddStripeMetadataToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :stripe_metadata, :jsonb, default: {}
    add_index  :projects, :stripe_metadata, using: :gin
  end
end