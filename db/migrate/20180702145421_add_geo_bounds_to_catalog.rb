class AddGeoBoundsToCatalog < ActiveRecord::Migration
  def change
    add_column :catalogs, :bounds, :jsonb, :null => true
  end
end
