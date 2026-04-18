class CreatePortfolioSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolio_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :project_url, null: false
      t.string :title, null: false
      t.text :description
      t.string :tech_tags, array: true, default: []
      t.string :status, null: false, default: "pending"
      t.text :admin_notes

      t.timestamps
    end
  end
end