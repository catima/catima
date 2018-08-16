class AddVisibleToCatalogs < ActiveRecord::Migration[4.2]
  def up
    add_column :catalogs, :visible, :boolean, :null => false, default: true
  end

  def down
    remove_column :catalogs, :visible
  end
end
