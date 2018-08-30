class AddGeoBoundsToCatalog < ActiveRecord::Migration[4.2]
  def change
    add_column :catalogs, :bounds, :jsonb, :null => true
  end
end
