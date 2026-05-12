class FixPaperTrailItemIdToString < ActiveRecord::Migration[8.1]
  def up
    change_column :versions, :item_id, :string
  end

  def down
    change_column :versions, :item_id, :bigint
  end
end