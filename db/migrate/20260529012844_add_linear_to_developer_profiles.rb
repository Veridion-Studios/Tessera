class AddLinearToDeveloperProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :developer_profiles, :linear_access_token,  :string
    add_column :developer_profiles, :linear_workspace_name, :string
    add_column :developer_profiles, :linear_team_id,        :string
    add_column :developer_profiles, :linear_team_name,      :string
    add_column :devlog_entries,     :linear_issue_id,       :string
    add_column :devlog_entries,     :linear_issue_url,      :string
    add_column :devlog_entries,     :linear_issue_title,    :string
  end
end