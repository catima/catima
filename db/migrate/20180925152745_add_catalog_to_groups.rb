class AddCatalogToGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :catalog, index: true, foreign_key: true
    add_index :groups, [:name, :catalog_id], unique: true
  end
end
