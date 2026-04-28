class AddGithubAppInstallationToDeveloperProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :developer_profiles, :github_app_installation_id, :bigint
    add_column :developer_profiles, :github_app_installation_account, :string
    add_index :developer_profiles, :github_app_installation_id
  end
end
