class AddGithubAccessTokenToDeveloperProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :developer_profiles, :github_access_token, :string
  end
end
