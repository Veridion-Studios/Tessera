class RemoveGithubAppFieldsFromDeveloperProfiles < ActiveRecord::Migration[8.1]
  def change
    remove_column :developer_profiles, :github_app_installation_id, :bigint
    remove_column :developer_profiles, :github_app_installation_account, :string
  end
end