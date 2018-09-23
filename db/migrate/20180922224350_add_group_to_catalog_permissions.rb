class AddGroupToCatalogPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_permissions, :group_id, :integer
  end
end
