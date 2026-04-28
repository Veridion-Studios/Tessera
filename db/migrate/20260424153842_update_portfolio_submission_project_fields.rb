class UpdatePortfolioSubmissionProjectFields < ActiveRecord::Migration[8.1]
  def change
    rename_column :portfolio_submissions, :project_url, :github_repo_url
    add_column :portfolio_submissions, :project_demo_url, :string

    add_index :portfolio_submissions, :github_repo_url
  end
end
