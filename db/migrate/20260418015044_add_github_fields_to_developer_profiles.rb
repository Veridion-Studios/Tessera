class AddGithubFieldsToDeveloperProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :developer_profiles, :github_uid, :string
    add_column :developer_profiles, :github_username, :string
    add_column :developer_profiles, :github_url, :string
    add_column :developer_profiles, :github_connected_at, :datetime
  end
end
