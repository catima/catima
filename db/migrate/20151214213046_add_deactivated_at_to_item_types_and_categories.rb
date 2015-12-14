class AddDeactivatedAtToItemTypesAndCategories < ActiveRecord::Migration
  def change
    add_column :categories, :deactivated_at, :datetime
    add_column :item_types, :deactivated_at, :datetime
  end
end
