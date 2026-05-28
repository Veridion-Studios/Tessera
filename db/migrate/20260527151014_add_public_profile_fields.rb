class AddPublicProfileFields < ActiveRecord::Migration[8.1]
  def change
    # Username for /profile/:username URLs — unique, URL-safe
    add_column :users, :username, :string
    add_index  :users, :username, unique: true

    # Developer profile enrichment
    add_column :developer_profiles, :bio,          :text
    add_column :developer_profiles, :availability, :string, default: "open"
    add_column :developer_profiles, :location,     :string
    add_column :developer_profiles, :website_url,  :string
    add_column :developer_profiles, :twitter_handle, :string
  end
end