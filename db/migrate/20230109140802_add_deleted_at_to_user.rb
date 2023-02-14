class AddDeletedAtToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :deleted_at, :datetime
  end

  def down
    remove_column :users, :deleted_at
  end
end
