class RemoveBoundsFromCatalog < ActiveRecord::Migration[5.2]
  def up
    remove_column :catalogs, :bounds
  end

  def down
    add_column :catalogs, :bounds, :jsonb, :null => true
  end
end
