class AddDeletedAt < ActiveRecord::Migration[6.1]
  def up
    add_column :choice_sets, :deleted_at, :datetime
    rename_column :categories, :deactivated_at, :deleted_at
    rename_column :item_types, :deactivated_at, :deleted_at
  end

  def down
    remove_column :choice_sets, :deleted_at, :datetime
    rename_column :categories, :deleted_at, :deactivated_at
    rename_column :item_types, :deleted_at, :deactivated_at
  end
end
